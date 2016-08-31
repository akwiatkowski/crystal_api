# require "crystal_api"

pg_connect_from_yaml($db_yaml_path)

crystal_model(EventModel, id : (Int32 | Nil) = nil, name : (String | Nil) = nil)
crystal_resource_full_rest(event, events, events, EventModel)

crystal_migrate_event
crystal_clear_table_event

Kemal.config.port = 8002
