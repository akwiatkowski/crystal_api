require "json"

abstract class CrystalApi::CrystalService
  def initialize(a)
    @adapter = a
    @columns = ["id"]
  end

  def index
    result = @adapter.get_objects("events", @columns)
    collection = result.rows.map{|r| self.class.from_row(r[0], r[1].to_s) }

    return collection
  end

  def show(db_id)
    result = @adapter.get_objects("events", db_id, @columns)
    collection = result.rows.map{|r| self.class.from_row(r[0], r[1].to_s) }

    if collection.size == 0
      return nil
    else
      return collection[0]
    end
  end

  def create(params)
    result = @adapter.insert_object("events", params)
    collection = result.rows.map{|r| self.class.from_row(r[0], r[1].to_s) }
    return collection[0]
  end

  def update(db_id, params)
    result = @adapter.update_object("events", db_id, params)
    collection = result.rows.map{|r| self.class.from_row(r[0], r[1].to_s) }
    return collection[0]
  end

  def delete(db_id)
    result = @adapter.delete_object("events", db_id)
    collection = result.rows.map{|r| self.class.from_row(r[0], r[1].to_s) }
    return collection[0]
  end

  def self.from_row(db_id, name)
    return {id: 1, name: "a"}
    #return CrystalApi::CrystalModel.new(db_id, name)
  end
end
