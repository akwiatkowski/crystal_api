require "http/server"

require "kemal/kemal/request"
require "kemal/kemal/param_parser"
require "kemal/kemal/exceptions"

require "./context"
require "./route_handler"
require "./auth_route_handler"

require "./adapters/pg_adapter"
require "./crystal_model"
require "./crystal_auth"

require "./services/rest_service"
require "./services/devise_session_service"

require "./controllers/base_controller"
require "./controllers/home_controller"
require "./controllers/json_rest_api_controller"
require "./controllers/devise_session_controller"

class CrystalApi::App
  property :port, :home_controller_enabled
  getter :adapter

  def initialize(db_adapter)
    @port = 8002
    @home_controller_enabled = true

    @adapter = db_adapter

    @logger = HTTP::LogHandler.new(STDOUT)
    @route_handler = CrystalApi::AuthRouteHandler.new
    @controllers = Array(CrystalApi::Controllers::BaseController).new

    @home_controller = CrystalApi::Controllers::HomeController.new
  end

  def add_controller(controller)
    @controllers << controller
  end

  def auth
    @route_handler.auth
  end

  def start
    prepare_routes

    server = HTTP::Server.new(@port, [@logger, @route_handler])
    puts "Running"
    server.listen
  end

  def run
    start
  end

  private def prepare_routes
    if home_controller_enabled
      add_controller(@home_controller)
    end

    @controllers.each do |controller|
      controller.prepare_routes(@route_handler)
    end
  end

end
