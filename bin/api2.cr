require "../src/crystal_api"

class CrystalApi::PgAdapter
  def self.config_path
    "config/database.yml"
  end
end

class CatModel < CrystalApi::CrystalModel
  def initialize(_db_id, _name, _age, _color)
    @db_id = _db_id as Int32
    @name = _name as String
    @age = _age.to_s.to_i as Int32
    @color = _color as String
  end

  getter :db_id, :name, :age, :color

  JSON.mapping({
    "db_id": Int32,
    "name": String,
    "age": Int32,
    "color": String
    })

  DB_COLUMNS = {
    #"id" is default
    "name" => "varchar(255)",
    "age" => "integer",
    "color" => "varchar(255)"
  }
  DB_TABLE = "cats"
end

class CatsService < CrystalApi::CrystalService
  def initialize(a)
    @adapter = a
    @table_name = CatModel::DB_TABLE
    create_table(CatModel::DB_COLUMNS)
  end

  def self.from_row(rh)
    return CatModel.new(rh["id"].to_i, rh["name"], rh["age"].to_s.to_i, rh["color"])
  end
end

class CatsController < CrystalApi::CrystalController
  def initialize(s)
    @service = s

    @router = {
      "GET /cats" => "index",
      "GET /cats/:id" => "show",
      "POST /cats" => "create",
      "PUT /cats/:id" => "update",
      "DELETE /cats/:id" => "delete"
    }

    @resource_name = "cat"
  end
end

class ApiApp < CrystalApi::App
  def initialize
    super

    @cats_service = CatsService.new(@adapter)
    @cats_controller = CatsController.new(@cats_service)

    @app.controller(@cats_controller)

    @port = 8000
  end

end


a = ApiApp.new
a.run
