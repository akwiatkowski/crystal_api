require "kemal/kemal/route_handler"
require "./route"
require "./json_messages"

# this content is used from from https://github.com/sdogruyol/kemal

# Kemal::RouteHandler is the main handler which handles all the HTTP requests. Routing, parsing, rendering e.g
# are done in this handler.
class CrystalApi::RouteHandler < Kemal::RouteHandler
  def call(context)
    # context.set_json_headers
    process_request(context)
  end

  # Processes the route if it's a match. Otherwise renders 404.
  def process_request(context)
    CrystalApi::Route.check_for_method_override!(context.request)
    lookup = @tree.find radix_path(context.request.override_method as String, context.request.path)

    unless lookup.found?
      context.response.print(JsonMessages.route_not_found)
      context.set_error_not_found
      return context
    end

    route = lookup.payload as CrystalApi::Route
    context.request.url_params = lookup.params
    context.response.print(route.handler.call(context).to_s)
    context
  end

  # Adds a given route to routing tree. As an exception each `GET` route additionaly defines
  # a corresponding `HEAD` route.
  def add_route(method, path, &handler : HTTP::Server::Context -> _)
    add_to_radix_tree method, path, CrystalApi::Route.new(method, path, &handler)
    add_to_radix_tree("HEAD", path, CrystalApi::Route.new("HEAD", path, &handler)) if method == "GET"
  end
end
