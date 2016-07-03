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
  def initialize(@pg : ConnectionPool(PG::Connection))
  end

  # def convert_response_to_array(response)
  #   array = [] of Hash(String, PgType)
  #   response.rows.each do |row|
  #     h = Hash(String, PgType).new
  #     response.fields.each_with_index do |field, i|
  #       h[field.name] = row[i]
  #     end
  #     array << h
  #   end
  #
  #   return array
  # end

  # def get_all_objects(collection)
  #   sql = "select * from #{collection};"
  #   db = @pg.connection
  #   result = db.exec(sql)
  #   @pg.release
  #
  #   puts sql
  #   puts result.rows.inspect
  #
  #   return convert_response_to_array(result)
  # end

  def get_all_objects(collection)
    sql = "select * from #{collection};"
    db = @pg.connection
    result = db.exec(sql)
    @pg.release
    return result
  end


end
