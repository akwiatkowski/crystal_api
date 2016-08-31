# require "crystal_api"

pg_connect_from_yaml($db_yaml_path)

crystal_model(EventModel, id : (Int32 | Nil) = nil, name : (String | Nil) = nil)
crystal_resource event, events, events, EventModel

Kemal.config.port = 8002
