require "spec"
require "../src/crystal_api"
require "./api/api"

PORT = 8002

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

pg_connect_from_yaml(db_yaml_path)

crystal_clear_table_now_user
crystal_clear_table_now_payment
crystal_clear_table_now_event

CrystalInit.start_spawned_and_wait
