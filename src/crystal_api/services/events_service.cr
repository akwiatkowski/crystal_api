require "json"

class CrystalApi::Service::EventsService
  def initialize(_adapter)
    @adapter = _adapter
    @columns = CrystalApi::Model::Event::DB_COLUMNS
  end

  def index
    result = @adapter.get_objects("events", @columns)
    collection = result.rows.map{|r| CrystalApi::Model::Event.new(r[0], r[1].to_s) }

    return collection
  end

  def show(db_id)
    result = @adapter.get_objects("events", db_id, @columns)
    collection = result.rows.map{|r| CrystalApi::Model::Event.new(r[0], r[1].to_s) }

    if collection.size == 0
      return nil
    else
      return collection[0]
    end
  end

  def create(params)
    result = @adapter.insert_object("events", params)
    collection = result.rows.map{|r| CrystalApi::Model::Event.new(r[0], r[1].to_s) }
    return collection[0]
  end

  def update(db_id, params)
    result = @adapter.update_object("events", db_id, params)
    collection = result.rows.map{|r| CrystalApi::Model::Event.new(r[0], r[1].to_s) }
    return collection[0]
  end

  def delete(db_id)
    result = @adapter.delete_object("events", db_id)
    collection = result.rows.map{|r| CrystalApi::Model::Event.new(r[0], r[1].to_s) }
    return collection[0]
  end
end
