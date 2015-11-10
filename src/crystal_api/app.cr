require "moonshine"

require "./pg_adapter"
require "./crystal_model"
require "./crystal_service"
require "./crystal_controller"

class CrystalApi::App

  def initialize
    @app = Moonshine::Base::App.new
    @adapter = CrystalApi::PgAdapter.new
  end

  def run
    @app.run
  end

end
