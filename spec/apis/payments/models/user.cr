require "./payment"

crystal_model(
  User,
  id : (Int32 | Nil) = nil,
  email : (String | Nil) = nil,
  hashed_password : (String | Nil) = nil,
  handle : (String | Nil) = nil
)
crystal_resource_convert(user, User)
crystal_resource_migrate(user, users, User)
crystal_resource_model_methods(user, users, User)

crystal_migrate_user
crystal_clear_table_user

struct User
  # Return id in UserHash if user is signed ok
  def self.sign_in(email : String, password : String) : UserHash
    service = CrystalService.instance
    h = {
      "email"           => email,
      "hashed_password" => Crypto::MD5.hex_digest(password),
    }
    result = service.get_filtered_objects("users", h)
    collection = crystal_resource_convert_user(result)

    # try sign in using handle
    if collection.size == 0
      h = {
        "handle"          => email,
        "hashed_password" => Crypto::MD5.hex_digest(password),
      }
      result = service.get_filtered_objects("users", h)
      collection = crystal_resource_convert_user(result)
    end

    uh = UserHash.new
    if collection.size > 0
      uh["id"] = collection[0].id
    end
    return uh
  end

  # Return email and handle if user can be loaded
  def self.load_user(user : Hash) : UserHash
    uh = UserHash.new
    return uh if user["id"].to_s == ""

    service = CrystalService.instance
    h = {
      "id" => user["id"].to_s.to_i.as(Int32),
    }
    result = service.get_filtered_objects("users", h)
    collection = crystal_resource_convert_user(result)

    if collection.size > 0
      uh["id"] = collection[0].id
      uh["email"] = collection[0].email
      uh["handle"] = collection[0].handle
    end
    return uh
  end

  def incoming_payments_amount
    sql_incoming = "select sum(payments.amount) as sum
      from payments
      where payments.user_id = #{self.id}
      and payments.payment_type = '#{Payment::TYPE_INCOMING}';"

    result = CrystalService.instance.execute_sql(sql_incoming)
    amount = result.rows[0][0]

    if amount.nil?
      return 0
    else
      return amount.to_s.to_i32
    end
  end

  def outgoing_payments_amount
    sql_incoming = "select sum(payments.amount) as sum
      from payments
      where payments.user_id = #{self.id}
      and payments.payment_type = '#{Payment::TYPE_OUTGOING}';"

    result = CrystalService.instance.execute_sql(sql_incoming)
    amount = result.rows[0][0]

    if amount.nil?
      return 0
    else
      return amount.to_s.to_i32
    end
  end

  def incoming_transfers_amount
    sql_incoming = "select sum(payments.amount) as sum
      from payments
      where payments.destination_user_id = #{self.id}
      and payments.payment_type = '#{Payment::TYPE_TRANSFER}';"

    result = CrystalService.instance.execute_sql(sql_incoming)
    amount = result.rows[0][0]

    if amount.nil?
      return 0
    else
      return amount.to_s.to_i32
    end
  end

  def outgoing_transfers_amount
    sql_incoming = "select sum(payments.amount) as sum
      from payments
      where payments.user_id = #{self.id}
      and payments.payment_type = '#{Payment::TYPE_TRANSFER}';"

    result = CrystalService.instance.execute_sql(sql_incoming)
    amount = result.rows[0][0]

    if amount.nil?
      return 0
    else
      return amount.to_s.to_i32
    end
  end

  def balance
    incoming_payments_amount - outgoing_payments_amount + incoming_transfers_amount - outgoing_transfers_amount
  end
end
