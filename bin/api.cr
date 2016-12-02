require "../src/crystal_api"

pg_connect_from_yaml(File.join(["config", "database.yml"]))

# define model
crystal_model(EventModel, id : Int32, name : String)
crystal_resource_full_rest(event, events, events, EventModel)

# migrations are not ready
# crystal_migrate_event

Kemal.config.logging = false
Kemal.config.port = 8002
Kemal.run
