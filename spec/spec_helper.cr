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

crystal_drop_now_user
crystal_drop_now_payment
crystal_drop_now_event

crystal_migrate_now_user
crystal_migrate_now_payment
crystal_migrate_now_event

CrystalInit.start_spawned_and_wait

CrystalService.logging = true
