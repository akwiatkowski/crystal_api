require "moonshine"

class Api
  include Moonshine
  include Moonshine::Utils::Shortcuts
  #include Moonshine::Base

  def initialize

    app = Moonshine::Base::App.new

    # respond to all HTTP verbs
    app.route "/", do |request|
      ok("Hello Moonshine!")
    end

    # or particular HTTP verbs
    app.get "/get", do |request|
      ok("This is a get response")
    end

    # you can set response headers
    app.get "/api", do |request|
      res = ok("{\"name\": \"moonshine\"}")
      res.headers["Content-type"] = "text/json"
      res
    end

    app.run(8000)


  end
end

a = Api.new
