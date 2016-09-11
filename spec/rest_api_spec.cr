require "./spec_helper"

describe EventRestApi do
  it "run simple REST API" do
    endpoint = "/events"
    host = "http://localhost:#{PORT}"
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
  end

  it "get object by name using model methods" do
    # create
    name = "Name to where #{Time.now.epoch}"
    h = {"name" => name}
    EventModel.create(h)

    # find
    collection = EventModel.fetch_all(where: h)

    collection.size.should eq 1
    collection[0].name.should eq name

    # delete
    collection[0].delete

    # find after delete
    collection = EventModel.fetch_all(where: h)

    collection.size.should eq 0
  end
end
