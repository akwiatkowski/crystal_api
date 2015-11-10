require "moonshine"

require "./pg_adapter"

require "./crystal_logger"
require "./crystal_model"
require "./crystal_service"
require "./crystal_controller"

class CrystalApi::App
  def initialize
    @app = Moonshine::Base::App.new
    @app.middleware_object CrystalApi::CrystalLogger.new
    @adapter = CrystalApi::PgAdapter.new
    @port
  end

  property :port

  def run
    @app.run(@port)
  end
end
