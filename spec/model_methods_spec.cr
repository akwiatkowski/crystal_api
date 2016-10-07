require "./spec_helper"

describe CrystalApi do
  it "get model instance using fetch method" do
    crystal_clear_table_now_user
    crystal_clear_table_now_payment

    sample_user1_email = "email1@email.org"
    sample_user1_handle = "user1"
    sample_user1_password = "password1"

    sample_user2_email = "email2@email.org"
    sample_user2_handle = "user2"
    sample_user2_password = "password1"

    # fixtures
    # user
    h = {
      "email"           => sample_user1_email,
      "handle"          => sample_user1_handle,
      "hashed_password" => Crypto::MD5.hex_digest(sample_user1_password),
    }
    user = User.create(h)

    h = {
      "email"           => sample_user2_email,
      "handle"          => sample_user2_handle,
      "hashed_password" => Crypto::MD5.hex_digest(sample_user2_password),
    }
    user = User.create(h)

    # test fetching

    # 1. find_by_email -> User
    users = User.fetch_all(where: {"email" => sample_user1_email})

    users.size.should eq 1
    users[0].email.should eq sample_user1_email
    users[0].handle.should eq sample_user1_handle
    user_id = users[0].id

    # 2. find_by_email -> nil
    users = User.fetch_all(where: {"email" => "makutas@posampas.com"})
    users.size.should eq 0

    # 3. find_all
    users = User.fetch_all
    users.size.should eq 2

    # 4. find(id)
    users = User.fetch_all(where: {"id" => user_id})
    users.size.should eq 1
    users[0].email.should eq sample_user1_email
    users[0].handle.should eq sample_user1_handle

    # fixtures - payments
    # payments
    (1..20).each do |i|
      h = {
        "user_id"      => user_id,
        "amount"       => i * 10,
        "created_at"   => Time.now,
        "payment_type" => Payment::TYPE_INCOMING,
      }
      Payment.create(h)
    end

    # test fetching
    # 5. where(user_id, payment_type, amount)
    amount = 2 * 10
    payments = Payment.fetch_all(
      where: {
        "user_id"      => user_id,
        "payment_type" => Payment::TYPE_INCOMING,
        "amount"       => amount,
      }
    )
    payments.size.should eq 1
    payments[0].amount.should eq amount
    payments[0].user_id.should eq user_id

    # 6. limit(5).order("id desc")
    limit = 5
    payments = Payment.fetch_all(
      limit: limit,
      order: "id desc"
    )
    payments.size.should eq limit

    # 7. delete last
    limit = 1
    payments = Payment.fetch_all(
      limit: limit,
      order: "id desc"
    )
    payments[0].delete

    puts payments.inspect

    # 8. find(id) -> not exist
    payments = Payment.fetch_all(where: {"id" => payments[0].id})
    payments.size.should eq 0
  end

  it "duplicate model instance" do
    crystal_clear_table_now_user
    crystal_clear_table_now_payment

    sample_user1_email = "email1@email.org"
    sample_user1_handle = "user1"
    sample_user1_password = "password1"

    sample_user2_email = "email2@email.org"
    sample_user2_handle = "user2"
    sample_user2_password = "password1"

    h = {
      "email"           => sample_user1_email,
      "handle"          => sample_user1_handle,
      "hashed_password" => Crypto::MD5.hex_digest(sample_user1_password),
    }
    user = User.create(h).not_nil!

    h2 = user.to_h
    # new_user = User.create(h2).not_nil! # primary key error

    h2.delete("id")
    new_user = User.create(h2).not_nil!

    user.email.should eq new_user.email
    user.handle.should eq new_user.handle
    user.hashed_password.should eq new_user.hashed_password
  end

  it "select using custom where clause" do
    crystal_clear_table_now_user
    crystal_clear_table_now_payment

    sample_user1_email = "email1@email.org"
    sample_user1_handle = "user1"
    sample_user1_password = "password1"

    h = {
      "email"           => sample_user1_email,
      "handle"          => sample_user1_handle,
      "hashed_password" => Crypto::MD5.hex_digest(sample_user1_password),
    }
    user = User.create(h).not_nil!

    users = User.fetch_all(where_sql: "email = '#{sample_user1_email}'")
    users.size.should eq 1
    users[0].email.should eq sample_user1_email
  end
end
