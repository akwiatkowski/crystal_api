require "http/server"

require "kemal/kemal/request"
require "kemal/kemal/param_parser"
require "kemal/kemal/exceptions"

require "./context"
require "./route_handler"

require "./adapters/pg_adapter"
require "./crystal_model"
require "./crystal_service"

require "./controllers/base_controller"
require "./controllers/home_controller"
require "./controllers/json_rest_api_controller"

class CrystalApi::App
  property :port

  def initialize
    @port = 8002
    @route_handler = CrystalApi::RouteHandler.new
    @controllers = Array(CrystalApi::Controllers::BaseController).new
  end

  def add_controller(controller)
    @controllers << controller
  end

  def prepare_routes
    @controllers.each do |controller|
      controller.prepare_routes(@route_handler)
    end
  end

  def start
    prepare_routes

    server = HTTP::Server.new(@port, [HTTP::LogHandler.new(STDOUT), @route_handler])
    server.listen
  end
end
