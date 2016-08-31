require "spec"
require "../src/crystal_api"

def http_run(method = "GET", ep = "", payload_string = "")
  return "curl --silent -H \"Content-Type: application/json\" -X #{method} #{ep} #{payload_string}"
end

# DB connection
$db_yaml_path = "config/travis.yml"
$local_path = "config/database.yml"
$db_yaml_path = $local_path if File.exists?($local_path)
