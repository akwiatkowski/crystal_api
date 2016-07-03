require "kemal/kemal/route_handler"
require "./route"
require "./json_messages"

# this content is used from from https://github.com/sdogruyol/kemal

class CrystalApi::RouteHandler
  def initialize
    @tree = Radix::Tree(CrystalApi::Route).new
  end

  property tree

  def call(context)
    process_request(context)
  end

  # Adds a given route to routing tree. As an exception each `GET` route additionaly defines
  # a corresponding `HEAD` route.
  def add_route(method, path, &handler : HTTP::Server::Context -> _)
    add_to_radix_tree method, path, CrystalApi::Route.new(method, path, &handler)
    add_to_radix_tree("HEAD", path, CrystalApi::Route.new("HEAD", path, &handler)) if method == "GET"
  end

  # Check if a route is defined and returns the lookup
  def lookup_route(verb, path)
    @tree.find radix_path(verb, path)
  end

  # Processes the route if it's a match. Otherwise renders 404.
  def process_request(context)
    lookup = @tree.find radix_path(context.request.method, context.request.path)

    unless lookup.found?
      context.response.print(JsonMessages.route_not_found)
      context.set_error_not_found
      return context
    end

    route = lookup.payload.as(CrystalApi::Route)
    context.request.url_params = lookup.params
    context.response.print(route.handler.call(context).to_s)
    context
  end

  private def radix_path(method : String, path)
    "/#{method.downcase}#{path}"
  end

  private def add_to_radix_tree(method, path, route)
    node = radix_path method, path
    @tree.add node, route
  end
end
