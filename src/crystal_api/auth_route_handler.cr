require "./route_handler"
require "./crystal_auth"

class CrystalApi::AuthRouteHandler < CrystalApi::RouteHandler
  getter :auth

  def initialize
    @tree = Radix::Tree.new
    @auth = CrystalApi::CrystalAuth.new
  end

  def call(context)
    process_request(context)
  end

  # Processes the route if it's a match. Otherwise renders 404.
  def process_request(context)
    CrystalApi::Route.check_for_method_override!(context.request)
    lookup = @tree.find(radix_path(context.request.override_method as String, context.request.path))

    unless lookup.found?
      context.response.print(JsonMessages.route_not_found)
      context.set_error_not_found
      return context
    end

    route = lookup.payload as CrystalApi::Route
    context.request.url_params = lookup.params
    if @auth.auth_context(context)
      context.response.print(route.handler.call(context).to_s)
      context
    else
      context.response.print(JsonMessages.forbidden)
      context.set_error_forbidden
      return context
    end

  end
end
