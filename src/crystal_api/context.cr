require "kemal/kemal/context"

class HTTP::Server::Context
  @time_mark : (Float64 | Nil)
  @db_time_cost : (Float64 | Nil)
  @params_hash : (Hash(String, AllParamTypes) | Nil)
  @params_processed : (Bool | Nil)

  property :get_user_from_token_f

  def params
    if @params_processed.nil?
      pp = Kemal::ParamParser.new(@request)
      @params_hash = pp.json

      merge_param(pp.url) if pp.url.any?
      merge_param(pp.query) if pp.query.any?
      merge_param(pp.body) if pp.body.any?
    end

    return @params_hash as Hash(String, AllParamTypes)
  end

  # a bit dirty hax
  def merge_param(p)
    h = @params_hash as Hash(String, AllParamTypes)
    p.keys.each do |k|
      h[k] = p[k]
    end
  end

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
