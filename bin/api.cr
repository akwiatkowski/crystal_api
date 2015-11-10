require "../src/crystal_api"

class EventModel < CrystalApi::CrystalModel
  def initialize(_db_id, _name)
    @db_id = _db_id as Int32
    @name = _name as String
  end

  property :db_id
  property :name

  JSON.mapping({
    "db_id": Int32,
    "name": String
    })

  DB_COLUMNS = [
    "id",
    "name"
  ]
end

class EventsService < CrystalApi::CrystalService
  def initialize(a)
    @adapter = a
    @columns = EventModel::DB_COLUMNS
  end

  def self.from_row(db_id, name)
    return EventModel.new(db_id, name)
  end
end

class EventsController < CrystalApi::CrystalController
  def initialize(s)
    @service = s

    @router = {
      "GET /events" => "index"
    }
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
