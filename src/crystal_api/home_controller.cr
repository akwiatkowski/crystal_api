class CrystalApi::HomeController < Moonshine::Base::Controller
  include Moonshine
  include Moonshine::Utils::Shortcuts
  include Moonshine::Base

  actions :index, :help

  def initialize
    @started_at = Time.now
    @router = {
      "GET /"       => "index",
      "GET /routes" => "help",
    }

    @global_routes = {
      "api" => @router,
    }
  end

  def index(req)
    ok "Welcome to CrystalApi instance. Uptime #{Time.now - @started_at}. Check GET /routes to list of all endpoints."
  end

  def help(req)
    ok @global_routes.to_json
  end

  def register_controller(c)
    @global_routes[c.resource_name] = c.router
  end
end
