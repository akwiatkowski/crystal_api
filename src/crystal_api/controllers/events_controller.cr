require "../models/event"
require "../pg"

class EventsController < Moonshine::Base::Controller
  include Moonshine
  include Moonshine::Utils::Shortcuts
  include Moonshine::Base

  actions :index, :show, :create, :update
  property :service

  def initialize()
    @viewcount = 0
    @router = {
      "GET /events" => "index",
      "GET /events/:id" => "show",
      "POST /events" => "create",
      "PUT /events/:id" => "update"
    }
  end

  def index(req)
    service = @service as CrystalApi::Service::EventsService
    ok service.index.to_json
  end

  def show(req)
    service = @service as CrystalApi::Service::EventsService
    ok service.show(req.params["id"]).to_json
  end

  # curl -H "Content-Type: application/json" -X POST -d '{"event":{"name": "test1"}}' http://localhost:8001/events
  def create(req)
    service = @service as CrystalApi::Service::EventsService
    params = (JSON::Parser.new(req.body).parse) as Hash(String, JSON::Type)
    object_params = params["event"] as Hash(String, JSON::Type)
    object_hash = {"name" => object_params["name"].to_s}

    ok service.create(object_hash).to_json
  end

  # curl -H "Content-Type: application/json" -X PUT -d '{"event":{"name": "test2"}}' http://localhost:8001/events
  def update(req)
    service = @service as CrystalApi::Service::EventsService
    params = (JSON::Parser.new(req.body).parse) as Hash(String, JSON::Type)
    object_params = params["event"] as Hash(String, JSON::Type)
    db_id = req.params["id"]
    object_hash = {"name" => object_params["name"].to_s}
    ok service.update(db_id, object_hash).to_json
  end


end
