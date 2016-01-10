module CrystalApi::Controllers::Utils
  def set_header_content(response, type)
    response.set_header("Content-type", type)
    return response
  end

  def set_json_headers(response)
    set_header_content(response, "application/json")
    return response
  end

  def add_time_cost_headers(response, db_time_cost)
    response.set_header("X-time-db", db_time_cost.to_s)
    return response
  end

  def t_from
    Time.now.epoch_f
  end

  def t_diff(t)
    return ((Time.now.epoch_f - t) * 1000_000.0).round
  end

  def bad_request
    return Response.new(404, "Bad request")
  end
end
