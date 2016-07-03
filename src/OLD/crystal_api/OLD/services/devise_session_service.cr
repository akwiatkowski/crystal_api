require "json"
require "crypto/bcrypt/password"

abstract class CrystalApi::DeviseSessionService
  property :encrypted_password_column

  def initialize(a)
    @adapter = a
    @table_name = "table"
  end

  def create(params)
    array = @adapter.get_object(@table_name, conditions: ["email = '#{params["email"]}'"])
    if array.size == 0
      return nil
    else
      rh = array[0]
      compared_password = params["password"].to_s
      encrypted_password = rh["encrypted_password"].to_s

      password_object = Crypto::Bcrypt::Password.new(encrypted_password)
      if password_object == compared_password
        return self.class.from_row(rh)
      else
        return nil
      end
    end
  end

  def get_user(user_id)
    array = @adapter.get_object(@table_name, conditions: ["id = #{user_id}"])
    if array.size == 0
      return nil
    else
      rh = array[0]
      return self.class.from_row(rh)
    end
  end

  def self.from_row(r)
    # return CrystalApi::CrystalModel.new(r["id"])
    return nil
  end
end
