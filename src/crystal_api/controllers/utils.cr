module CrystalApi::Controllers::Utils
  def set_header_content(response, type)
    response.set_header("Content-type", type)
    return response
  end

  def set_json_headers(response)
    set_header_content(response, "application/json")
    return response
  end
end
