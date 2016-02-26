require "./adapters/pg_adapter"

require "./crystal_logger"
require "./crystal_model"
require "./crystal_service"
require "./controllers/*"

class CrystalApi::App
  def initialize(a)
    @adapter = a

    # @app = Moonshine::Core::App.new
    # @app.middleware_object CrystalApi::CrystalLogger.new

    @home_controller = CrystalApi::Controllers::HomeController.new
    @port = 8000
  end

  property :port, :adapter

  def add_controller(c)
    # @home_controller.register_controller(c)
    # @app.controller(c)
  end

  def run
    # @app.controller(@home_controller)
    # @app.run(@port)
  end
end
