require "crystal-pg/pg"
require "yaml"

class CrystalApi::Pg
  def initialize
    config = YAML.load(File.read("config/database.yml")) as Hash(YAML::Type, YAML::Type)
    pg_string = "postgres://#{config["host"]}/#{config["database"]}?user=#{config["user"]}&password=#{config["password"]}"

    @db = PG.connect(pg_string)
  end

  def get_objects(collection)
    sql = "select * from #{collection};"
    return @db.exec(sql)
  end

  def insert_object(collection, attributes)
    sql = "insert into #{collection} (name) values ('#{attributes["name"]}');"
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
