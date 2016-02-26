# ApiServer - instance of HTTP:S there
# ApiHandler - register all controllers there
# process request, search throught controllers
# every controller has method `call` which will execute proper action method
# action method only return value
# ApiHandler get format, by default it is json (if html force to json)
# ApiHandler



require "http/server"
require "radix"

class Route < Kemal::Route
end




# class Controller < HTTP::Handler
#   def call(context)
#     puts context.request.path
#     puts context.request.method
#
#     p = Kemal::ParamParser.new("/", context.request)
#     params = p.parse
#
#     puts params.inspect
#     puts "*"
#     # puts get_params(context.request).inspect
#
#     context.response.content_type = "text/plain"
#     context.response.print "{\"db_id\": 2}"
#     return context
#   end
#
#   def get_params(request : HTTP::Request)
#     # get request path
#     path = request.path
#     params = {} of String => String
#     path_items = path.to_s.split("/")
#     pattern_items = @pattern.split("/")
#     path_items.size.times do |i|
#       if pattern_items[i].match(/(:\w*)/)
#         params[pattern_items[i].gsub(/:/, "")] = path_items[i]
#       end
#     end
#     return params
#   end
# end

class ApiServer
  property :port

  def initialize
    @port = 8002
    @route_handler = RouteHandler.new

    @route_handler.add_route("GET", "/") do |context|
      "1"
    end
  end

  def start
    server = HTTP::Server.new(8002, [HTTP::LogHandler.new(STDOUT), @route_handler])
    server.listen
  end
end

a = ApiServer.new
a.port = 8002
a.start
