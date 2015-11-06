require "crystal-pg/pg"
require "yaml"

class CrystalApi::PgAdapter
  def initialize
    config = YAML.load(File.read("config/database.yml")) as Hash(YAML::Type, YAML::Type)
    pg_string = "postgres://#{config["host"]}/#{config["database"]}?user=#{config["user"]}&password=#{config["password"]}"

    @db = PG.connect(pg_string)
  end

  def get_objects(collection, columns)
    sql = "select #{columns.join(", ")} from #{collection};"
    return @db.exec(sql)
  end

  def get_objects(collection, db_id, columns)
    sql = "select #{columns.join(", ")} from #{collection} where id = #{db_id};"
    return @db.exec(sql)
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
    return @db.exec(sql)
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
    return @db.exec(sql)
  end

  def delete_object(collection, db_id)
    sql = "delete from only #{collection} where id = #{db_id} returning *;"
    return @db.exec(sql)
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

  def create_table(collection)
    sql = "create table if not exists #{collection} (
      id serial,
      name varchar(255),
      primary key(id)
    )"
    return @db.exec(sql)
  end
end
