require "./utils"

class CrystalApi::Controllers::HomeController < Moonshine::Controller
  include Moonshine
  include Moonshine::Utils::Shortcuts
  include CrystalApi::Controllers::Utils

  actions :index, :help

  def initialize
    @started_at = Time.now
    @router = {
      "GET /hello"  => "index",
      "GET /routes" => "help",
    }

    @global_routes = {
      "api" => @router,
    }
  end

  def index(req)
    response = ok({"message" => "Welcome to CrystalApi instance. Uptime #{Time.now - @started_at}. Check GET /routes to list of all endpoints."}.to_json)
    set_json_headers(response)
    return response
  end

  def help(req)
    ok @global_routes.to_json
  end

  def register_controller(c)
    @global_routes[c.resource_name] = c.router
  end
end
