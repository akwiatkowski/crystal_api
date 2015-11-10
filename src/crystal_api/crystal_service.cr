require "json"

abstract class CrystalApi::CrystalService
  def initialize(a)
    @adapter = a
    @table_name = "table"
  end

  def index
    array = @adapter.get_objects(@table_name)
    collection = array.map{|rh| self.class.from_row(rh) }
    return collection
  end

  def show(db_id)
    array = @adapter.get_object(@table_name, db_id)
    collection = array.map{|rh| self.class.from_row(rh) }

    if collection.size == 0
      return nil
    else
      return collection[0]
    end
  end

  def create(params)
    array = @adapter.insert_object(@table_name, params)
    collection = array.map{|rh| self.class.from_row(rh) }
    return collection[0]
  end

  def update(db_id, params)
    array = @adapter.update_object(@table_name, db_id, params)
    collection = array.map{|rh| self.class.from_row(rh) }
    return collection[0]
  end

  def delete(db_id)
    array = @adapter.delete_object(@table_name, db_id)
    collection = array.map{|rh| self.class.from_row(rh) }
    return collection[0]
  end

  def create_table(db_columns)
    @adapter.create_table(@table_name, db_columns)
  end

  def self.from_row(r)
    #return CrystalApi::CrystalModel.new(r["id"])
    return nil
  end
end
