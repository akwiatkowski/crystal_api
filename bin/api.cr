require "../src/crystal_api"

class CrystalApi::PgAdapter
  def self.config_path
    "config/database.yml"
  end
end

class EventModel < CrystalApi::CrystalModel
  def initialize(_db_id, _name)
    @db_id = _db_id as Int32
    @name = _name as (String | Nil)
  end

  getter :db_id, :name

  JSON.mapping({
    "db_id": Int32,
    "name":  String,
  })

  DB_COLUMNS = {
    # "id" is default
    "name" => "varchar(255)",
  }
  DB_TABLE = "events"
end

class EventsService < CrystalApi::CrystalService
  def initialize(a)
    @adapter = a
    @table_name = EventModel::DB_TABLE

    # create table if not exists
    create_table(EventModel::DB_COLUMNS)
  end

  def self.from_row(rh)
    return EventModel.new(rh["id"], rh["name"])
  end
end

class EventsController < CrystalApi::CrystalController
  def initialize(s)
    @service = s

    @router = {
      "GET /events"        => "index",
      "GET /events/:id"    => "show",
      "POST /events"       => "create",
      "PUT /events/:id"    => "update",
      "DELETE /events/:id" => "delete",
    }

    @resource_name = "event"
  end
end

class ApiApp < CrystalApi::App
  def initialize
    super

    @events_service = EventsService.new(@adapter)
    @events_controller = EventsController.new(@events_service)

    add_controller(@events_controller)

    @port = 8002
  end
end

a = ApiApp.new
a.run
