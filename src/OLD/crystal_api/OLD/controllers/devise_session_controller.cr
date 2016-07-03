require "secure_random"
require "jwt"
require "./base_controller"
require "../json_messages"

abstract class CrystalApi::Controllers::DeviseSessionApiController < CrystalApi::Controllers::BaseController
  getter :resource_name, :router

  def initialize(s, secret_key = SecureRandom.hex)
    @service = s
    @path = "/session"
    @resource_name = "user"
    @secret = secret_key
  end

  def prepare_routes(route_handler : CrystalApi::RouteHandler)
    route_handler.add_route("POST", @path) do |context|
      create(context)
    end
  end

  # curl -H "Content-Type: application/json" -X POST -d '{"user":{"email": "email@email.org", "password": "password"}}' http://localhost:8002/session
  def create(context)
    context.set_json_headers
    service = @service.as(CrystalApi::DeviseSessionService)
    object_params = context.params[@resource_name].as(Hash(String, JSON::Type))

    context.mark_time_pre_db
    resource = service.create(object_params)
    context.mark_time_post_db

    if resource
      context.set_status_created
      context.set_time_cost_headers
      return token_response(resource)
    else
      context.set_error_bad_request
      return JsonMessages.bad_request
    end
  end

  def token_response(resource)
    payload = {"user_id" => resource.db_id}
    token = JWT.encode(payload, @secret, "HS256")

    return {"token": token}.to_json
  end

  def token_to_user(token)
    begin
      payload, header = JWT.decode(token, @secret, "HS256")
      if payload.is_a?(Hash) && payload.has_key?("user_id")
        user_id = payload["user_id"]
        service = @service.as(CrystalApi::DeviseSessionService)
        user = service.get_user(user_id)
        return user
      end
    rescue JWT::DecodeError
      return nil
    end
    return nil
  end
end
