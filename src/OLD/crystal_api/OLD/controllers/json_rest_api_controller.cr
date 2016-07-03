require "./base_controller"
require "../json_messages"

abstract class CrystalApi::Controllers::JsonRestApiController < CrystalApi::Controllers::BaseController
  getter :resource_name, :router

  def initialize(s)
    @service = s

    @actions = [
      "index",
      "show",
      "create",
      "update",
      "delete",
    ] of String

    @path = "/resources"

    # @router = {
    #   "GET /resources"        => "index",
    #   "GET /resources/:id"    => "show",
    #   "POST /resources"       => "create",
    #   "PUT /resources/:id"    => "update",
    #   "DELETE /resources/:id" => "delete",
    # }

    @resource_name = "resource"
  end

  def prepare_routes(route_handler : CrystalApi::RouteHandler)
    if @actions.includes?("index")
      route_handler.add_route("GET", @path) do |context|
        index(context)
      end
    end

    if @actions.includes?("show")
      route_handler.add_route("GET", @path + "/:id") do |context|
        show(context)
      end
    end

    if @actions.includes?("create")
      route_handler.add_route("POST", @path) do |context|
        create(context)
      end
    end

    if @actions.includes?("update")
      route_handler.add_route("PUT", @path + "/:id") do |context|
        update(context)
      end
      route_handler.add_route("PATCH", @path + "/:id") do |context|
        update(context)
      end
    end

    if @actions.includes?("delete") || @actions.includes?("destroy")
      route_handler.add_route("DELETE", @path + "/:id") do |context|
        delete(context)
      end
    end
  end

  def index(context)
    context.set_json_headers
    service = @service.as(CrystalApi::RestService)

    context.mark_time_pre_db
    collection = service.index
    context.mark_time_post_db

    response = collection.to_json
    context.set_time_cost_headers
    context.set_status_ok

    return response
  end

  def show(context)
    context.set_json_headers
    service = @service.as(CrystalApi::RestService)

    context.mark_time_pre_db
    resource = service.show(context.params["id"])
    context.mark_time_post_db

    if resource
      context.set_status_ok
      context.set_time_cost_headers
      return resource.to_json
    else
      context.set_error_not_found
      return JsonMessages.not_found
    end
  end

  # curl -H "Content-Type: application/json" -X POST -d '{"event":{"name": "test1"}}' http://localhost:8002/events
  def create(context)
    context.set_json_headers
    service = @service.as(CrystalApi::RestService)
    object_params = context.params[@resource_name].as(Hash(String, JSON::Type))

    context.mark_time_pre_db
    resource = service.create(object_params)
    context.mark_time_post_db

    if resource
      context.set_status_created
      context.set_time_cost_headers
      return resource.to_json
    else
      context.set_error_bad_request
      return JsonMessages.bad_request
    end
  end

  # curl -H "Content-Type: application/json" -X PUT -d '{"event":{"name": "test2"}}' http://localhost:8002/events/2
  def update(context)
    context.set_json_headers
    service = @service.as(CrystalApi::RestService)
    object_params = context.params[@resource_name].as(Hash(String, JSON::Type))
    db_id = context.params["id"]

    context.mark_time_pre_db
    resource = service.update(db_id, object_params)
    context.mark_time_post_db

    if resource
      context.set_status_ok
      context.set_time_cost_headers
      return resource.to_json
    else
      context.set_error_not_found
      return JsonMessages.not_found
    end
  end

  # curl -H "Content-Type: application/json" -X DELETE http://localhost:8002/events/2
  def delete(context)
    context.set_json_headers
    service = @service.as(CrystalApi::RestService)

    context.mark_time_pre_db
    resource = service.delete(context.params["id"])
    context.mark_time_post_db

    if resource
      context.set_status_ok
      context.set_time_cost_headers
      return resource.to_json
    else
      context.set_error_not_found
      return JsonMessages.not_found
    end
  end
end
