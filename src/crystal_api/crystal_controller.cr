abstract class CrystalApi::CrystalController < Moonshine::Base::Controller
  actions :index

  include Moonshine
  include Moonshine::Utils::Shortcuts
  include Moonshine::Base

  property :service

  def index(req)
    service = @service as CrystalApi::CrystalService
    ok service.index.to_json
  end

  def show(req)
    service = @service as CrystalApi::CrystalService
    ok service.show(req.params["id"]).to_json
  end

  # curl -H "Content-Type: application/json" -X POST -d '{"event":{"name": "test1"}}' http://localhost:8001/events
  def create(req)
    service = @service as CrystalApi::CrystalService
    params = (JSON::Parser.new(req.body).parse) as Hash(String, JSON::Type)
    object_params = params["event"] as Hash(String, JSON::Type)
    object_hash = {"name" => object_params["name"].to_s}

    ok service.create(object_hash).to_json
  end

  # curl -H "Content-Type: application/json" -X PUT -d '{"event":{"name": "test2"}}' http://localhost:8001/events/1
  def update(req)
    service = @service as CrystalApi::CrystalService
    params = (JSON::Parser.new(req.body).parse) as Hash(String, JSON::Type)
    object_params = params["event"] as Hash(String, JSON::Type)
    db_id = req.params["id"]
    object_hash = {"name" => object_params["name"].to_s}

    ok service.update(db_id, object_hash).to_json
  end

  # curl -H "Content-Type: application/json" -X DELETE http://localhost:8001/events/1
  def delete(req)
    service = @service as CrystalApi::CrystalService
    ok service.delete(req.params["id"]).to_json
  end

end
