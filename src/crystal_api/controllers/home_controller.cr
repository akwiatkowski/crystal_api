require "./base_controller"

class CrystalApi::Controllers::HomeController < CrystalApi::Controllers::BaseController
  def prepare_routes(route_handler : CrystalApi::RouteHandler)
    route_handler.add_route("GET", "/") do |context|
      "a"
    end
  end
end
