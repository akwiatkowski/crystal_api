require "moonshine"

require "./pg_adapter"

require "./crystal_logger"
require "./crystal_model"
require "./crystal_service"
require "./crystal_controller"

require "./home_controller"

class CrystalApi::App
  def initialize
    @app = Moonshine::Base::App.new
    @app.middleware_object CrystalApi::CrystalLogger.new

    @home_controller = CrystalApi::HomeController.new

    @adapter = CrystalApi::PgAdapter.new
    @port = 8000
  end

  property :port

  def add_controller(c)
    @home_controller.register_controller(c)
    @app.controller(c)
  end

  def run
    @app.controller(@home_controller)
    @app.run(@port)
  end
end
