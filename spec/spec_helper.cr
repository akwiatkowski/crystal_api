require "spec"
require "../src/crystal_api"

# DB connection
def db_yaml_path
  path = "config/travis.yml"
  local_path = "config/database.yml"
  path = local_path if File.exists?(local_path)

  return path
end

def http_run(method = "GET", ep = "", payload_string = "")
  return "curl --silent -H \"Content-Type: application/json\" -X #{method} #{ep} #{payload_string}"
end
