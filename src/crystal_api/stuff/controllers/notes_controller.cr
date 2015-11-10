class NotesController < CrystalApi::Controller
  actions :index, :show, :create, :update, :delete

  def initialize
    @viewcount = 0
    @router = {
                "GET /events"        => "index",
                "GET /events/:id"    => "show",
                "POST /events"       => "create",
                "PUT /events/:id"    => "update",
                "DELETE /events/:id" => "delete",
              }
  end
end
