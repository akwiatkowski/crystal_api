require "moonshine"

require "./pg_adapter"
require "./crystal_model"
require "./crystal_service"
require "./crystal_controller"

require "./controllers/home_controller"

class CrystalApi::App
  include Moonshine
  include Moonshine::Utils::Shortcuts

  def initialize
    @app = Moonshine::Base::App.new
    @adapter = CrystalApi::PgAdapter.new

    #@home_controller = CrystalApi::HomeController.new

    #@events_service = CrystalApi::Service::EventsService.new(@adapter)
    #@events_controller = EventsController.new
    #@events_controller.service = @events_service

    #@app.controller(HomeController.new)
    #@app.controller(@events_controller)
  end

  def run
    @app.run(8001)
  end

end
