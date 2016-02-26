require "http"

class CrystalApi::Server
  property :port

  def initialize
    @port = 8002
    @controller = Controller.new
  end

  def start
    server = HTTP::Server.new(8002, [HTTP::LogHandler.new(STDOUT), @controller])
    server.listen
  end
end
