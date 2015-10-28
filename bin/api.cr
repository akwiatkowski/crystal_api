require "../src/crystal_api"
require "../src/crystal_api/models/event"

#p = CrystalApi::Pg.new
#p.insert_object("events", {"name" => Time.now.to_s})
#collection_pg = p.get_objects("events")
#collection = collection_pg.rows.map{|r| Models::Event.from_row(r)}
#puts collection.inspect

a = CrystalApi::App.new
