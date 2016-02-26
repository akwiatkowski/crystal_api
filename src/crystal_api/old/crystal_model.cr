require "json"

abstract class CrystalApi::CrystalModel
  DB_COLUMNS = ["id", "name"] of String

  def initialize(db_id, name)
    @db_id = db_id
    @name = name
  end

  getter :db_id, :name
end
