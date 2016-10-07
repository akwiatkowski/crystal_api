require "yaml"

alias PgType = (Array(PG::Geo::Point) | Bool | Char | Float32 | Float64 | Int16 | Int32 | Int64 | JSON::Any | PG::Geo::Box | PG::Geo::Circle | PG::Geo::Line | PG::Geo::LineSegment | PG::Geo::Path | PG::Geo::Point | PG::Numeric | Slice(UInt8) | String | Time | UInt32 | Nil)

class HTTP::Server::Context
  property! crystal_service : CrystalService
end

def pg_connect_from_yaml(yaml_file, capacity = 25, timeout = 0.1)
  kca = Kemal::CrystalApi.from_yaml(yaml_file)
  Kemal.config.add_handler(kca)
end

class Kemal::CrystalApi < HTTP::Handler
  def initialize(pg_url : String)
    @pg = PG.connect(pg_url).as(PG::Connection)
    @crystal_service = CrystalService.new(@pg)
  end

  def self.from_yaml(yaml_path)
    return self.new(url_from_yaml(yaml_path))
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
  @@logging = false

  def initialize(@pg : PG::Connection)
  end

  def self.logging=(b : Bool)
    @@logging = b
  end

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

  # Copied from Kemal logger
  private def elapsed_text(elapsed)
    millis = elapsed.total_milliseconds
    return "#{millis.round(2)}ms" if millis >= 1

    "#{(millis * 1000).round(2)}µs"
  end

  # Execute plain SQL query
  def execute_sql(sql)
    time = Time.now

    # db = @pg.connection # pool
    db = @pg
    result = db.exec(sql)
    # @pg.release # pool

    if @@logging
      elapsed_text = elapsed_text(Time.now - time)
      l = Kemal.config.logger.not_nil!
      l.write(time)
      l.write("    ") # request status
      l.write(" ")
      l.write("SQL")
      l.write(" ")
      l.write(sql)
      l.write(" -- ")
      l.write(elapsed_text.to_s)
      l.write("\n")
    end

    return result
  end

  def execute_sql_single_result(sql)
    result = execute_sql(sql)
    return result.rows[0][0]
  end

  # Fetch all model instances
  def fetch_all(
                collection : String,
                where : Hash = {} of String => PgType,
                where_sql : String = "",
                limit : Int32 = 25,
                order : String = "")
    sql = "select * from \"#{collection}\""

    # where
    wc = CrystalService.convert_to_where_clause(where)
    wc = where_sql unless where_sql.to_s == "" # force custom SQL
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

  # Fetch all model instances
  def count(
                collection : String,
                where : Hash = {} of String => PgType,
                where_sql : String = "",
                )
    sql = "select count(*) from \"#{collection}\""

    # where
    wc = CrystalService.convert_to_where_clause(where)
    wc = where_sql unless where_sql.to_s == "" # force custom SQL
    if wc.size > 0
      sql += " where #{wc}"
    end

    sql += ";"

    result = execute_sql_single_result(sql)
    return result
  end

  def fetch_one(
                collection : String,
                where : Hash = {} of String => PgType,
                where_sql : String = "",
                order : String = "")
    return fetch_all(
      collection: collection,
      where: where,
      where_sql: where_sql,
      limit: 1,
      order: order
    )
  end

  def insert_into_table(collection : String, hash : Hash = {} of String => PgType)
    columns = [] of String
    values = [] of String

    hash.keys.each do |column|
      columns << column
      value = hash[column]
      values << self.class.escape_value(value)
    end

    sql = "insert into #{collection} (#{columns.join(", ")}) values (#{values.join(", ")}) returning *;"

    result = execute_sql(sql)
    return result
  end

  def update_all(
                 collection : String,
                 where : Hash = {} of String => PgType,
                 where_sql : String = "",
                 hash : Hash = {} of String => PgType)
    columns = [] of String
    values = [] of String

    hash.keys.each do |column|
      columns << column
      value = hash[column]
      values << self.class.escape_value(value)
    end

    sql = "update only #{collection} set (#{columns.join(", ")}) = (#{values.join(", ")})"

    # where
    wc = CrystalService.convert_to_where_clause(where)
    wc = where_sql unless where_sql.to_s == "" # force custom SQL
    if wc.size > 0
      sql += " where #{wc}"
    end

    sql += " returning *;"

    result = execute_sql(sql)
    return result
  end

  def update_one(
                 collection : String,
                 id : Int32,
                 hash : Hash = {} of String => PgType)
    return update_all(
      collection: collection,
      where: {"id" => id},
      hash: hash
    )
  end

  def delete_all(
                 collection : String,
                 where : Hash = {} of String => PgType,
                 where_sql : String = ""
                 )
    sql = "delete from only #{collection}"

    # where
    wc = CrystalService.convert_to_where_clause(where)
    wc = where_sql unless where_sql.to_s == "" # force custom SQL
    if wc.size > 0
      sql += " where #{wc}"
    end

    sql += " returning *;"

    result = execute_sql(sql)
    return result
  end

  def delete_one(
                 collection : String,
                 id : Int32)
    return delete_all(
      collection: collection,
      where: {"id" => id}
    )
  end

  # Faster way to get CrystalService
  def self.instance
    handler = Kemal::Config::HANDLERS.select { |h| h.as?(Kemal::CrystalApi) }.first.as(Kemal::CrystalApi)
    service = handler.crystal_service
    return service
  end
end
