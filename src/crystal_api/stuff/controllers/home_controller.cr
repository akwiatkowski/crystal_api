class HomeController < Moonshine::Base::Controller
  include Moonshine
  include Moonshine::Utils::Shortcuts
  include Moonshine::Base

  actions :index

  def initialize
    @viewcount = 0
    @router = {
                "GET /" => "index",
              }
  end

  def index(req)
    @viewcount += 1
    ok("This page has been visited #{@viewcount} times.")
  end
end
