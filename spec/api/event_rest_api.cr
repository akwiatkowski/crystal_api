class EventRestApi
end

crystal_model(
  EventModel,
  id : (Int32 | Nil) = nil,
  name : (String | Nil) = nil
)
crystal_resource_full_rest(event, events, events, EventModel)

crystal_migrate_event
