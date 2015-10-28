require "moonshine"

require "./controllers/home_controller"
require "./controllers/events_controller"

class CrystalApi::App
  include Moonshine
  include Moonshine::Utils::Shortcuts

  def initialize
    @app = Moonshine::Base::App.new

    @app.controller(HomeController.new)
    @app.controller(EventsController.new)

    @app.run(8000)
  end

end
