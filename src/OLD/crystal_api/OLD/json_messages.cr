class CrystalApi::JsonMessages
  ERROR_ROUTE_NOT_FOUND = "route_not_found"
  ERROR_NOT_FOUND       = "not_found"
  ERROR_BAD_REQUEST     = "bad_request"
  ERROR_FORBIDDEN       = "forbidden"

  def self.error_message(content)
    "{\"error\": \"#{content}\"}"
  end

  def self.route_not_found
    error_message(ERROR_ROUTE_NOT_FOUND)
  end

  def self.not_found
    error_message(ERROR_NOT_FOUND)
  end

  def self.bad_request
    error_message(ERROR_BAD_REQUEST)
  end

  def self.forbidden
    error_message(ERROR_FORBIDDEN)
  end
end
