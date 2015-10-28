require "../models/event"

class EventsController < Moonshine::Base::Controller
  include Moonshine
  include Moonshine::Utils::Shortcuts
  include Moonshine::Base

  actions :index, :show

  def initialize()
    @viewcount = 0
    @router = {
      "GET /events" => "index",
      "GET /events/:id/" => "show",
    }
  end

  def index(req)
    ok "Events"
  end

  def show(req)
    ok "Event #{req.params.inspect}"
  end

end
