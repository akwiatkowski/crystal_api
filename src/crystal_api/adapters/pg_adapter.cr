require "crystal-pg/pg"
require "yaml"

class CrystalApi::Adapters::PgAdapter
  def self.config_path
    "config/database.yml"
  end

  def initialize
    config = YAML.load(File.read(self.class.config_path)) as Hash(YAML::Type, YAML::Type)
    pg_string = "postgres://#{config["host"]}/#{config["database"]}?user=#{config["user"]}&password=#{config["password"]}"

    @db = PG.connect(pg_string)
  end

  def convert_response_to_array(response)
    array = [] of Hash(String, (Nil | String | Int32 | Int16 | Int64 | Float32 | Float64 | Bool | Time | Slice(UInt8) | Hash(String, JSON::Type) | Array(JSON::Type) ) )
    response.rows.each do |row|
      h = Hash(String, (Nil | String | Int32 | Int16 | Int64 | Float32 | Float64 | Bool | Time | Slice(UInt8) | Hash(String, JSON::Type) | Array(JSON::Type)) ).new
      response.fields.each_with_index do |field, i|
        h[ field.name ] = row[i]
      end
      array << h
    end

    return array
  end

  def get_objects(collection)
    sql = "select * from #{collection};"
    return convert_response_to_array( @db.exec(sql) )
  end

  def get_object(collection, db_id)
    sql = "select * from #{collection} where id = #{db_id};"
    return convert_response_to_array( @db.exec(sql) )
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
    return convert_response_to_array( @db.exec(sql) )
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
    return convert_response_to_array( @db.exec(sql) )
  end

  def delete_object(collection, db_id)
    sql = "delete from only #{collection} where id = #{db_id} returning *;"
    return convert_response_to_array( @db.exec(sql) )
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
      columns.map{|a| "#{a} #{columns[a]}"}.join(", ") + ",
      primary key(id)
    )"

    return @db.exec(sql)
  end
end
