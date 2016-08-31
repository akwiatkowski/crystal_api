require "yaml"

alias PgType = (Array(PG::Geo::Point) | Bool | Char | Float32 | Float64 | Int16 | Int32 | Int64 | JSON::Any | PG::Geo::Box | PG::Geo::Circle | PG::Geo::Line | PG::Geo::LineSegment | PG::Geo::Path | PG::Geo::Point | PG::Numeric | Slice(UInt8) | String | Time | UInt32 | Nil)

class HTTP::Server::Context
  property! crystal_service : CrystalService
end

class Kemal::PG < HTTP::Handler
  getter :pg
end

def pg_connect_from_yaml(yaml_file, capacity = 25, timeout = 0.1)
  kpg = Kemal::PG.new(
    Kemal::CrystalApi.url_from_yaml(yaml_file),
    capacity,
    timeout
  )
  Kemal.config.add_handler(kpg)

  kca = Kemal::CrystalApi.new(kpg.pg)
  Kemal.config.add_handler(kca)
end

class Kemal::CrystalApi < HTTP::Handler
  def initialize(@pg : ConnectionPool(PG::Connection))
    @crystal_service = CrystalService.new(@pg)
  end

  getter :crystal_service

  def call(context)
    context.crystal_service = @crystal_service
    call_next(context)
  end

  def self.url_from_yaml(path)
    config = YAML.parse(File.read(path))
    host = config["host"].to_s
    database = config["database"].to_s
    user = config["user"].to_s
    password = config["password"].to_s
    return "postgresql://#{user}:#{password}@#{host}/#{database}"
  end
end

class CrystalService
  def self.escape_value(value)
    if value.is_a?(Int32)
      return value.to_s
    elsif value.is_a?(String)
      return "'" + value.to_s + "'"
    else
      return "'" + value.to_s + "'"
    end
  end

  def self.convert_to_where_clause(hash : Hash) : String
    columns = [] of String
    values = [] of String

    hash.keys.each do |column|
      columns << column
      value = hash[column]
      values << escape_value(value)
    end

    conditions = [] of String

    columns.each_with_index do |column, i|
      conditions << "#{column} = #{values[i]}"
    end

    return "#{conditions.join(" and ")}"
  end

  def initialize(@pg : ConnectionPool(PG::Connection))
  end

  # Execute plain SQL query
  def execute_sql(sql)
    db = @pg.connection
    result = db.exec(sql)
    @pg.release
    return result
  end

  # Fetch all model instances
  def fetch_all(
      collection : String,
      where : Hash = {} of String => PgType,
      limit : Int32 = 25,
      order : String = ""
    )

    sql = "select * from \"#{collection}\""

    # where
    wc = CrystalService.convert_to_where_clause(where)
    if wc.size > 0
      sql += " where #{wc}"
    end

    # order
    if order != ""
      sql += " order by #{order}"
    end

    if limit > 0
      sql += " limit #{limit}"
    end

    sql += ";"

    db_result = execute_sql(sql)
    return db_result
  end

  def fetch_one(
      collection : String,
      where : Hash = {} of String => PgType,
      order : String = ""
    )

    return fetch_all(
        collection: collection,
        where: where,
        limit: 1,
        order: order
      )
  end

  def get_filtered_objects(collection, hash : Hash)
    wc = self.class.convert_to_where_clause(hash)

    sql = "select * from #{collection}"
    if wc.size > 0
      sql += " where #{wc}"
    end
    sql += ";"

    db = @pg.connection
    result = db.exec(sql)
    @pg.release
    return result
  end

  def insert_object(collection, hash)
    columns = [] of String
    values = [] of String

    hash.keys.each do |column|
      columns << column
      value = hash[column]
      values << self.class.escape_value(value)
    end

    sql = "insert into #{collection} (#{columns.join(", ")}) values (#{values.join(", ")}) returning *;"

    db = @pg.connection
    result = db.exec(sql)
    @pg.release
    return result
  end

  def update_object(collection, db_id, hash)
    columns = [] of String
    values = [] of String

    hash.keys.each do |column|
      columns << column
      value = hash[column]
      values << self.class.escape_value(value)
    end

    sql = "update only #{collection} set (#{columns.join(", ")}) = (#{values.join(", ")}) where id = #{db_id} returning *;"

    db = @pg.connection
    result = db.exec(sql)
    @pg.release
    return result
  end

  def delete_object(collection, db_id)
    sql = "delete from only #{collection} where id = #{db_id} returning *;"

    db = @pg.connection
    result = db.exec(sql)
    @pg.release
    return result
  end

  # Faster way to get CrystalService
  def self.instance
    handler = Kemal::Config::HANDLERS.select { |h| h.as?(Kemal::CrystalApi) }.first.as(Kemal::CrystalApi)
    service = handler.crystal_service
    return service
  end
end
