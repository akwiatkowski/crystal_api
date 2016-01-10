require "json"
require "colorize"

port = 8002
endpoint = "/events"
host = "http://localhost:#{port}"
path = "#{host}#{endpoint}"

random_name = Time.now.epoch.to_s
random_name2 = random_name.reverse

def http_run(method = "GET", ep = "", payload_string = "")
  return "curl --silent -H \"Content-Type: application/json\" -X #{method} #{ep} #{payload_string}"
end

# create
puts "CREATE".colorize(:light_blue)
command = http_run("POST", path, "-d '{\"event\":{\"name\": \"#{random_name}\"}}'")
puts "- #{command.colorize(:red)}"
response = `#{command}`
json = JSON.parse(response)
puts "= #{json.inspect.colorize(:green)}"
id = json["db_id"]

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

# update
puts "UPDATE".colorize(:light_blue)
command = http_run("PUT", path + "/#{id}", "-d '{\"event\":{\"name\": \"#{random_name2}\"}}'")
puts "- #{command.colorize(:red)}"
response = `#{command}`
json = JSON.parse(response)
puts "= #{(json.inspect[0..70] + "...").colorize(:green)}"

# delete
puts "DELETE".colorize(:light_blue)
command = http_run("DELETE", path + "/#{id}")
puts "- #{command.colorize(:red)}"
response = `#{command}`
json = JSON.parse(response)
puts "= #{(json.inspect[0..70] + "...").colorize(:green)}"
