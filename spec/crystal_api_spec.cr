require "./spec_helper"

def http_run(method = "GET", ep = "", payload_string = "")
  return "curl --silent -H \"Content-Type: application/json\" -X #{method} #{ep} #{payload_string}"
end

# crystal_api is powered by some powerful macros
# it must be put not within a block

path = "config/travis.yml"
local_path = "config/database.yml"
path = local_path if File.exists?(local_path)
pg_connect_from_yaml(path)

crystal_model(EventModel, id : (Int32 | Nil) = nil, name : (String | Nil) = nil)
crystal_resource event, events, events, EventModel
Kemal.config.port = 8002

# run Kemal no to block spec
spawn do
  Kemal.run
end

describe CrystalApi do
  it "check simple CRUD endpoint" do

    # wait for Kemal is ready
    while Kemal.config.server.nil?
      sleep 0.1
    end

    crystal_migrate_event # TODO a bit dirty at this moment

    port = 8002
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
    id = json["id"]

    json["name"].should eq random_name

    # index
    puts "INDEX".colorize(:light_blue)
    command = http_run("GET", path)
    puts "- #{command.colorize(:red)}"
    response = `#{command}`
    json = JSON.parse(response)
    puts "= #{(json.inspect[0..70] + "...").colorize(:green)}"

    # show
    puts "SHOW".colorize(:light_blue)
    command = http_run("GET", path + "/#{id}")
    puts "- #{command.colorize(:red)}"
    response = `#{command}`
    json = JSON.parse(response)
    puts "= #{(json.inspect[0..70] + "...").colorize(:green)}"

    json["name"].should eq random_name

    # update
    puts "UPDATE".colorize(:light_blue)
    command = http_run("PUT", path + "/#{id}", "-d '{\"event\":{\"name\": \"#{random_name2}\"}}'")
    puts "- #{command.colorize(:red)}"
    response = `#{command}`
    json = JSON.parse(response)
    puts "= #{(json.inspect[0..70] + "...").colorize(:green)}"

    json["name"].should eq random_name2

    # delete
    puts "DELETE".colorize(:light_blue)
    command = http_run("DELETE", path + "/#{id}")
    puts "- #{command.colorize(:red)}"
    response = `#{command}`
    json = JSON.parse(response)
    puts "= #{(json.inspect[0..70] + "...").colorize(:green)}"

    json["name"].should eq random_name2


    # close after
    Kemal.config.server.not_nil!.close

  end
end
