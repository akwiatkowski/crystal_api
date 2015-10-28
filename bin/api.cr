require "../src/crystal_api"

p = CrystalApi::Pg.new
p.insert_object("events", {"name" => Time.now.to_s})
collection = p.get_objects("events")

puts collection.inspect

a = CrystalApi::App.new
