require "./spec_helper"

CrystalInit.reset # reset migrations, delete_all, ...

require "./apis/payments/payments_api"

describe CrystalApi do
  it "get model instance using fetch method" do
    pg_connect_from_yaml($db_yaml_path)
    crystal_clear_table_now_user
    crystal_clear_table_now_payment
    CrystalInit.start_without_server

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
    service = User.service
    result = service.insert_object("users", h)

    h = {
      "email"           => sample_user2_email,
      "handle"          => sample_user2_handle,
      "hashed_password" => Crypto::MD5.hex_digest(sample_user2_password),
    }
    service = User.service
    result = service.insert_object("users", h)

    # test fetching

    # 1. find_by_email -> User
    users = User.fetch(where: {"email" => sample_user1_email})

    users.size.should eq 1
    users[0].email.should eq sample_user1_email
    users[0].handle.should eq sample_user1_handle
    user_id = users[0].id

    # 2. find_by_email -> nil
    users = User.fetch(where: {"email" => "makutas@posampas.com"})
    users.size.should eq 0

    # 3. find_all
    users = User.fetch
    users.size.should eq 2

    # 4. find(id)
    users = User.fetch(where: {"id" => user_id})
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
      result = service.insert_object("payments", h)
    end

    # test fetching
    # 5. where(user_id, payment_type, amount)
    amount = 2 * 10
    payments = Payment.fetch(
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
    payments = Payment.fetch(
      limit: limit,
      order: "id desc"
    )
    payments.size.should eq limit

    # 7. delete last
    limit = 1
    payments = Payment.fetch(
      limit: limit,
      order: "id desc"
    )
    payments[0].delete

    # 8. find(id) -> not exist
    payments = Payment.fetch(where: {"id" => user_id})
    payments.size.should eq 0


    # close after
    CrystalInit.stop
  end
end
