require "./spec_helper"
require "./apis/rest_events/api"


# run Kemal not to block spec code


# describe CrystalApi do
#   it "check simple CRUD endpoint" do

#     crystal_migrate_event # TODO a bit dirty at this moment
#
#     port = 8002
#     endpoint = "/events"
#     host = "http://localhost:#{port}"
#     path = "#{host}#{endpoint}"
#
#     random_name = Time.now.epoch.to_s
#     random_name2 = random_name.reverse
#
#     # create
#     puts "CREATE".colorize(:light_blue)
#     command = http_run("POST", path, "-d '{\"event\":{\"name\": \"#{random_name}\"}}'")
#     puts "- #{command.colorize(:red)}"
#     response = `#{command}`
#     json = JSON.parse(response)
#     puts "= #{json.inspect.colorize(:green)}"
#     id = json["id"]
#
#     json["name"].should eq random_name
#
#     # index
#     puts "INDEX".colorize(:light_blue)
#     command = http_run("GET", path)
#     puts "- #{command.colorize(:red)}"
#     response = `#{command}`
#     json = JSON.parse(response)
#     puts "= #{(json.inspect[0..70] + "...").colorize(:green)}"
#
#     # show
#     puts "SHOW".colorize(:light_blue)
#     command = http_run("GET", path + "/#{id}")
#     puts "- #{command.colorize(:red)}"
#     response = `#{command}`
#     json = JSON.parse(response)
#     puts "= #{(json.inspect[0..70] + "...").colorize(:green)}"
#
#     json["name"].should eq random_name
#
#     # update
#     puts "UPDATE".colorize(:light_blue)
#     command = http_run("PUT", path + "/#{id}", "-d '{\"event\":{\"name\": \"#{random_name2}\"}}'")
#     puts "- #{command.colorize(:red)}"
#     response = `#{command}`
#     json = JSON.parse(response)
#     puts "= #{(json.inspect[0..70] + "...").colorize(:green)}"
#
#     json["name"].should eq random_name2
#
#     # delete
#     puts "DELETE".colorize(:light_blue)
#     command = http_run("DELETE", path + "/#{id}")
#     puts "- #{command.colorize(:red)}"
#     response = `#{command}`
#     json = JSON.parse(response)
#     puts "= #{(json.inspect[0..70] + "...").colorize(:green)}"
#
#     json["name"].should eq random_name2
#
#
#     # close after
#
#   end
#
#   it "get object by name" do
#     service = CrystalService.instance
#
#     # create
#     name = "Name to where #{Time.now.epoch}"
#     h = {"name" => name}
#     result = service.insert_object("events", h)
#     collection = crystal_resource_convert_event(result)
#
#     # find
#     result = service.get_filtered_objects("events", h)
#     collection = crystal_resource_convert_event(result)
#
#     collection.size.should eq 1
#     collection[0].name.should eq name
#
#     # delete
#     service.delete_object("events", collection[0].id)
#
#     # find after delete
#     result = service.get_filtered_objects("events", h)
#     collection = crystal_resource_convert_event(result)
#
#     collection.size.should eq 0

#   end
# end
