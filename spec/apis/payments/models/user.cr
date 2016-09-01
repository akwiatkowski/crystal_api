require "./payment"

crystal_model(
  User,
  id : (Int32 | Nil) = nil,
  email : (String | Nil) = nil,
  hashed_password : (String | Nil) = nil,
  handle : (String | Nil) = nil
)
crystal_resource(user, users, User)

crystal_migrate_user
crystal_clear_table_user

struct User
  # Return id in UserHash if user is signed ok
  def self.sign_in(email : String, password : String) : UserHash
    h = {
      "email"           => email,
      "hashed_password" => Crypto::MD5.hex_digest(password),
    }

    # try sign in using handle
    user = User.fetch_one(where: h)
    if user.nil?
      h = {
        "handle"          => email,
        "hashed_password" => Crypto::MD5.hex_digest(password),
      }
      user = User.fetch_one(where: h)
    end

    uh = UserHash.new
    if user
      uh["id"] = user.id
    end
    return uh
  end

  # Return email and handle if user can be loaded
  def self.load_user(user : Hash) : UserHash
    uh = UserHash.new
    return uh if user["id"].to_s == ""

    h = {
      "id" => user["id"].to_s.to_i.as(Int32),
    }
    user = User.fetch_one(h)

    if user
      uh["id"] = user.id
      uh["email"] = user.email
      uh["handle"] = user.handle
    end
    return uh
  end

  private def payment_sql(t : String)
    return "select sum(payments.amount) as sum
    from payments
    where payments.user_id = #{self.id}
    and payments.payment_type = '#{t}';"
  end

  def incoming_payments_amount
    result = execute_sql(payment_sql(Payment::TYPE_INCOMING))
    amount = result.rows[0][0]

    if amount.nil?
      return 0
    else
      return amount.to_s.to_i32
    end
  end

  def outgoing_payments_amount
    result = execute_sql(payment_sql(Payment::TYPE_OUTGOING))
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
