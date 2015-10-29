require "crystal-pg/pg"
require "yaml"

class CrystalApi::Pg
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

  def insert_object(collection, columns, values)
    sql = "insert into #{collection} (#{columns.join(", ")}) values (#{values.join(", ")}) returning *;"
    return @db.exec(sql)
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
