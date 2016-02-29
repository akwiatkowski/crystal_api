require "kemal/kemal/context"

class HTTP::Server::Context
  @time_mark : (Float64 | Nil)
  @db_time_cost : (Float64 | Nil)

  property :get_user_from_token_f

  def mark_time_pre_db
    @time_mark = Time.now.epoch_f
  end

  def mark_time_post_db
    if @time_mark.is_a?(Float64)
      @db_time_cost = Time.now.epoch_f - (@time_mark as Float64)
    end
  end

  def set_json_headers
    response.content_type = "application/json"
  end

  def set_time_cost_headers
    if @db_time_cost.is_a?(Float64)
      response.headers["X-time-db"] = (@db_time_cost as Float64).to_s
    end
  end

  # Status
  def set_status_ok
    response.status_code = 200
  end

  def set_status_created
    response.status_code = 201
  end

  def set_error_not_found
    response.status_code = 404
  end

  def set_error_bad_request
    response.status_code = 400
  end

  def set_error_forbidden
    response.status_code = 403
  end

end
