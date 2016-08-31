require "spec"
require "../src/crystal_api"

def http_run(method = "GET", ep = "", payload_string = "")
  return "curl --silent -H \"Content-Type: application/json\" -X #{method} #{ep} #{payload_string}"
end

def start_kemal
  spawn do
    Kemal.run
  end

  while Kemal.config.server.nil?
    sleep 0.1
  end
end

def clear_kemal
  Kemal.config.handlers.clear
	Kemal::RouteHandler::INSTANCE.tree = Radix::Tree(Kemal::Route).new
  Kemal.config.server.not_nil!.close
end

# DB connection
$db_yaml_path = "config/travis.yml"
$local_path = "config/database.yml"
$db_yaml_path = $local_path if File.exists?($local_path)
