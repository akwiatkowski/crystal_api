require "../src/crystal_api"

class DbAdapter < CrystalApi::Adapters::PgAdapter
end

class EventModel < CrystalApi::CrystalModel
  def initialize(_db_id, _name)
    @db_id = _db_id as Int32
    @name = _name as (String | Nil)
  end

  getter :db_id, :name

  JSON.mapping({
    "db_id": Int32,
    "name":  (String | Nil),
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

class EventsController < CrystalApi::Controllers::JsonRestApiController
  def initialize(s)
    @service = s

    @actions = [
      "index",
      "show",
      "create",
      "update",
      "delete"
    ]

    @path = "/events"
    @resource_name = "event"
  end
end

a = CrystalApi::App.new(DbAdapter.new(config_path: "config/database.yml"))
a.port = 8002
a.add_controller( EventsController.new(EventsService.new(a.adapter)) )
a.start
