require "../models/event"
require "../pg"

class EventsController < Moonshine::Base::Controller
  include Moonshine
  include Moonshine::Utils::Shortcuts
  include Moonshine::Base

  actions :index, :show
  property :service

  def initialize()
    @viewcount = 0
    @router = {
      "GET /events" => "index",
      "GET /events/:id/" => "show",
    }
  end

  def index(req)
    service = @service as CrystalApi::Service::EventsService
    ok service.index.to_json
  end

  def show(req)
    service = @service as CrystalApi::Service::EventsService
    ok service.show(req.params["id"]).to_json
  end

end
