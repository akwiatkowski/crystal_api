require "json"

class CrystalApi::Service::EventsService
  def initialize(_adapter)
    @adapter = _adapter
  end

  def index
    result = @adapter.get_objects("events", ["id", "name"])
    collection = result.rows.map{|r| CrystalApi::Model::Event.new(r[0], r[1].to_s) }

    return collection
  end

  def show(db_id)
    result = @adapter.get_objects("events", db_id, ["id", "name"])
    collection = result.rows.map{|r| CrystalApi::Model::Event.new(r[0], r[1].to_s) }

    if collection.size == 0
      return nil
    else
      return collection[0]
    end
  end

  def create(params)
    result = @adapter.insert_object("events", ["name"], ["'" + params["name"] + "'"] )
    collection = result.rows.map{|r| CrystalApi::Model::Event.new(r[0], r[1].to_s) }
    return collection[0]
  end
end
