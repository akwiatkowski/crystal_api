require "../src/crystal_api"

class EventModel < CrystalApi::CrystalModel
  def initialize(_db_id, _name)
    @db_id = _db_id as Int32
    @name = _name as String
  end

  getter :db_id, :name

  JSON.mapping({
    "db_id": Int32,
    "name": String
    })

  DB_COLUMNS = [
    "id",
    "name"
  ]
  DB_TABLE = "events"
end

class EventsService < CrystalApi::CrystalService
  def initialize(a)
    @adapter = a
    @table_name = EventModel::DB_TABLE
  end

  def self.from_row(rh)
    return EventModel.new(rh["id"].to_i, rh["name"])
  end
end

class EventsController < CrystalApi::CrystalController
  def initialize(s)
    @service = s

    @router = {
      "GET /events" => "index",
      "GET /events/:id" => "show",
      "POST /events" => "create",
      "PUT /events/:id" => "update",
      "DELETE /events/:id" => "delete"      
    }

    @resource_name = "event"
  end
end

class ApiApp < CrystalApi::App
  def initialize
    super

    @events_service = EventsService.new(@adapter)
    @events_controller = EventsController.new(@events_service)

    @app.controller(@events_controller)
  end

end

a = ApiApp.new
a.run
