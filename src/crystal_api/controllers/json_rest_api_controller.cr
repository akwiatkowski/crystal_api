require "./utils"

abstract class CrystalApi::Controllers::JsonRestApiController < Moonshine::Controller
  include Moonshine
  include Moonshine::Utils::Shortcuts
  include CrystalApi::Controllers::Utils

  actions :index, :show, :create, :update, :delete

  getter :resource_name, :router

  def initialize(s)
    @service = s

    @router = {
      "GET /resources"        => "index",
      "GET /resources/:id"    => "show",
      "POST /resources"       => "create",
      "PUT /resources/:id"    => "update",
      "DELETE /resources/:id" => "delete",
    }

    @resource_name = "resource"
  end

  def index(req)
    service = @service as CrystalApi::CrystalService

    t = t_from
    collection = service.index
    ts = t_diff(t)

    response = ok(collection.to_json)
    add_time_cost_headers(response, ts)
    set_json_headers(response)
    return response
  end

  def show(req)
    service = @service as CrystalApi::CrystalService

    t = t_from
    resource = service.show(req.params["id"])
    ts = t_diff(t)

    if resource
      response = ok(resource.to_json)
    else
      response = not_found
    end
    
    add_time_cost_headers(response, ts)
    set_json_headers(response)
    return response
  end

  # curl -H "Content-Type: application/json" -X POST -d '{"event":{"name": "test1"}}' http://localhost:8001/events
  def create(req)
    service = @service as CrystalApi::CrystalService
    params = (JSON::Parser.new(req.body).parse) as Hash(String, JSON::Type)
    object_params = params[@resource_name] as Hash(String, JSON::Type)
    ok service.create(object_params).to_json
  end

  # curl -H "Content-Type: application/json" -X PUT -d '{"event":{"name": "test2"}}' http://localhost:8001/events/1
  def update(req)
    service = @service as CrystalApi::CrystalService
    params = (JSON::Parser.new(req.body).parse) as Hash(String, JSON::Type)
    object_params = params[@resource_name] as Hash(String, JSON::Type)
    db_id = req.params["id"]
    ok service.update(db_id, object_params).to_json
  end

  # curl -H "Content-Type: application/json" -X DELETE http://localhost:8001/events/1
  def delete(req)
    service = @service as CrystalApi::CrystalService
    ok service.delete(req.params["id"]).to_json
  end
end
