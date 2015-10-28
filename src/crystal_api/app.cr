require "moonshine"

require "./controllers/home_controller"
require "./controllers/events_controller"

require "./services/events_service"

class CrystalApi::App
  include Moonshine
  include Moonshine::Utils::Shortcuts

  def initialize
    @app = Moonshine::Base::App.new

    @adapter = CrystalApi::Pg.new

    @events_service = CrystalApi::Service::EventsService.new(@adapter)
    @events_controller = EventsController.new
    @events_controller.service = @events_service

    @app.controller(HomeController.new)
    @app.controller(@events_controller)

    @app.run(8000)
  end

end
