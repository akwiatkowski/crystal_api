require "http/server"

require "kemal/kemal/request"
require "kemal/kemal/param_parser"
require "kemal/kemal/exceptions"

require "./adapters/pg_adapter"

class CrystalApi::App
  property :port, :home_controller_enabled
  getter :adapter, :is_ready

  def initialize(
                 @db_adapter : CrystalApi::Adapters::AbstractDbAdapter,
                 @port = 8002,
                 @logger = HTTP::LogHandler.new(STDOUT))
    @is_ready = false
    @home_controller_enabled = true

    # @route_handler = CrystalApi::AuthRouteHandler.new
    # @controllers = Array(CrystalApi::Controllers::BaseController).new
    #
    # @home_controller = CrystalApi::Controllers::HomeController.new
  end

  def start
    # prepare_routes

    # server = HTTP::Server.new(@port, [@logger, @route_handler])
    server = HTTP::Server.new(@port, [@logger])

    puts "Running"

    @is_ready = true

    server.listen
  end
end

#   def add_controller(controller)
#     @controllers << controller
#   end
#
#   def auth
#     @route_handler.auth
#   end
#
#   def start
#     prepare_routes
#
#     server = HTTP::Server.new(@port, [@logger, @route_handler])
#     puts "Running"
#
#     @is_ready = true
#
#     server.listen
#   end
#
#   def run
#     start
#   end
#
#   private def prepare_routes
#     if home_controller_enabled
#       add_controller(@home_controller)
#     end
#
#     @controllers.each do |controller|
#       controller.prepare_routes(@route_handler)
#     end
#   end
#
# end
