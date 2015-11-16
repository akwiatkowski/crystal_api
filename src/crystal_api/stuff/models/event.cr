require "json"

class CrystalApi::Model::Event
  def initialize(_db_id, _name)
    @db_id = _db_id as Int32
    @name = _name as String
  end

  property :db_id
  property :name

  JSON.mapping({
    "db_id": Int32,
    "name":  String,
  })

  DB_COLUMNS = [
    "id",
    "name",
  ]
end
