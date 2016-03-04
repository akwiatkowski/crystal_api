require "pg/pg"
require "yaml"

class CrystalApi::Adapters::PgAdapter
  alias PgType = Nil | String | Int16 | Int32 | Int64 | Float32 | Float64 | Bool | Time | Slice(UInt8) | Hash(String, JSON::Any) | Array(JSON::Any) | JSON::Any

  def initialize(config_path = nil as (Nil | String), host = "localhost", database = "db", user = "postgres", password = "postgres")
    @host = host
    @database = database
    @user = user
    @password = password

    load_yaml(config_path) if config_path

    @pg = PG.connect(pg_string)
  end

  def load_yaml(config_path)
    config = YAML.parse(File.read(config_path))
    @host = config["host"]
    @database = config["database"]
    @user = config["user"]
    @password = config["password"]
  end

  def pg_string
    return "postgres://#{@host}/#{@database}?user=#{@user}&password=#{@password}"
  end

  private def db
    return @pg
  end

  def convert_response_to_array(response)
    array = [] of Hash(String, PgType)
    response.rows.each do |row|
      h = Hash(String, PgType).new
      response.fields.each_with_index do |field, i|
        h[field.name] = row[i]
      end
      array << h
    end

    return array
  end

  def get_all_objects(collection)
    sql = "select * from #{collection} where id = 1;"
    return convert_response_to_array(db.exec(sql))
  end

  def get_objects(collection, conditions = [] of String)
    sql = "select * from #{collection}"
    sql += conditions_to_where(conditions)
    sql += ";"
    return convert_response_to_array(db.exec(sql))
  end

  def conditions_to_where(conditions = [] of String)
    return "" if conditions.size == 0
    return " where " + conditions.join(" and ")
  end

  def get_object_by_id(collection, db_id)
    sql = "select * from #{collection} where id = #{db_id};"
    return convert_response_to_array(db.exec(sql))
  end

  def get_object(collection, conditions = [] of String, limit = 1)
    sql = "select * from #{collection}"
    sql += conditions_to_where(conditions)
    sql += " limit #{limit}" if limit > 0
    sql += ";"

    return convert_response_to_array(db.exec(sql))
  end

  def insert_object(collection, hash)
    columns = [] of String
    values = [] of String

    hash.keys.each do |column|
      columns << column
      value = hash[column]
      values << escape_value(value)
    end

    sql = "insert into #{collection} (#{columns.join(", ")}) values (#{values.join(", ")}) returning *;"
    return convert_response_to_array(db.exec(sql))
  end

  def update_object(collection, db_id, hash)
    columns = [] of String
    values = [] of String

    hash.keys.each do |column|
      columns << column
      value = hash[column]
      values << escape_value(value)
    end

    sql = "update only #{collection} set (#{columns.join(", ")}) = (#{values.join(", ")}) where id = #{db_id} returning *;"
    return convert_response_to_array(db.exec(sql))
  end

  def delete_object(collection, db_id)
    sql = "delete from only #{collection} where id = #{db_id} returning *;"
    return convert_response_to_array(db.exec(sql))
  end

  def escape_value(value)
    if value.is_a?(Int32)
      return value.to_s
    elsif value.is_a?(String)
      return "'" + value.to_s + "'"
    else
      return "'" + value.to_s + "'"
    end
  end

  def create_table(collection, columns)
    sql = "create table if not exists #{collection} (
      id serial,
      " +
      columns.map { |a| "#{a} #{columns[a]}" }.join(", ") + ",
      primary key(id)
    )"

    return db.exec(sql)
  end
end
