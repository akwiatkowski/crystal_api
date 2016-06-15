require "./spec_helper"
require "json"
require "colorize"

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

class EventsService < CrystalApi::RestService
  def initialize(a : CrystalApi::Adapters::PgAdapter)
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
  def initialize(s : CrystalApi::RestService)
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

def http_run(method = "GET", ep = "", payload_string = "")
  return "curl --silent -H \"Content-Type: application/json\" -X #{method} #{ep} #{payload_string}"
end

describe CrystalApi do
  it "run server and test full CRUD" do
    config_path = "config/database.yml"
    config_path = "config/travis.yml" unless File.exists?(config_path)

    a = CrystalApi::App.new(DbAdapter.new(config_path: config_path))
    port = 8002

    future do
      a.port = port
      a.add_controller( EventsController.new(EventsService.new(a.adapter)) )
      a.start
    end

    while a.is_ready == false
      sleep 0.001
    end

    endpoint = "/events"
    host = "http://localhost:#{port}"
    path = "#{host}#{endpoint}"

    random_name = Time.now.epoch.to_s
    random_name2 = random_name.reverse

    # create
    puts "CREATE".colorize(:light_blue)
    command = http_run("POST", path, "-d '{\"event\":{\"name\": \"#{random_name}\"}}'")
    puts "- #{command.colorize(:red)}"
    response = `#{command}`
    json = JSON.parse(response)
    puts "= #{json.inspect.colorize(:green)}"
    id = json["db_id"]

    # create - spec
    json["name"].should eq random_name

    # index
    puts "INDEX".colorize(:light_blue)
    command = http_run("GET", path)
    puts "- #{command.colorize(:red)}"
    response = `#{command}`
    json = JSON.parse(response)
    puts "= #{(json.inspect[0..70] + "...").colorize(:green)}"

    # index - spec
    json[json.as_a.size - 1]["db_id"].should eq id
    json[json.as_a.size - 1]["name"].should eq random_name

    # show
    puts "SHOW".colorize(:light_blue)
    command = http_run("GET", path + "/#{id}")
    puts "- #{command.colorize(:red)}"
    response = `#{command}`
    json = JSON.parse(response)
    puts "= #{(json.inspect[0..70] + "...").colorize(:green)}"

    # show - spec
    json["db_id"].should eq id
    json["name"].should eq random_name

    # update
    puts "UPDATE".colorize(:light_blue)
    command = http_run("PUT", path + "/#{id}", "-d '{\"event\":{\"name\": \"#{random_name2}\"}}'")
    puts "- #{command.colorize(:red)}"
    response = `#{command}`
    json = JSON.parse(response)
    puts "= #{(json.inspect[0..70] + "...").colorize(:green)}"

    # update - spec
    json["db_id"].should eq id
    json["name"].should eq random_name2

    # delete
    puts "DELETE".colorize(:light_blue)
    command = http_run("DELETE", path + "/#{id}")
    puts "- #{command.colorize(:red)}"
    response = `#{command}`
    json = JSON.parse(response)
    puts "= #{(json.inspect[0..70] + "...").colorize(:green)}"

    # update - spec
    json["db_id"].should eq id
    json["name"].should eq random_name2

  end
end
