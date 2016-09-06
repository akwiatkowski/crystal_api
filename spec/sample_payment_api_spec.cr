require "./spec_helper"

CrystalInit.reset # reset migrations, delete_all, ...

require "./apis/payments/payments_api"

describe CrystalApi do
  it "run payment transfer API, perform transfer, get user balance" do
    # connect DB, start migration
    # TODO put in something like prerun
    pg_connect_from_yaml(db_yaml_path)
    CrystalInit.start_spawned_and_wait

    sample_user1_email = "email1@email.org"
    sample_user1_handle = "user1"
    sample_user1_password = "password1"

    sample_user2_email = "email2@email.org"
    sample_user2_handle = "user2"
    sample_user2_password = "password1"

    service = CrystalService.instance

    # create user 1
    h = {"email" => sample_user1_email}
    user = User.fetch_one(where: h)
    if user.nil?
      # create user
      puts "Create user #{sample_user1_email}"

      h = {
        "email"           => sample_user1_email,
        "handle"          => sample_user1_handle,
        "hashed_password" => Crypto::MD5.hex_digest(sample_user1_password),
      }
      user = User.create(h)
      puts "User created - #{user.inspect}"
    else
      puts "User already available #{user.inspect}"
    end
    user1 = user.not_nil!
    user1_id = user1.id

    # create user 2
    h = {"email" => sample_user2_email}
    user = User.fetch_one(where: h)
    if user.nil?
      # create user
      puts "Create user #{sample_user2_email}"

      h = {
        "email"           => sample_user2_email,
        "handle"          => sample_user2_handle,
        "hashed_password" => Crypto::MD5.hex_digest(sample_user2_password),
      }
      user = User.create(h)
      puts "User created - #{user.inspect}"
    else
      puts "User already available #{user.inspect}"
    end
    user2 = user.not_nil!
    user2_id = user2.id

    # create initial payments
    h = {
      "user_id"      => user1_id,
      "amount"       => 1000,
      "payment_type" => Payment::TYPE_INCOMING,
    }
    Payment.create(h)

    h = {
      "user_id"             => user1_id,
      "destination_user_id" => user2_id,
      "amount"              => 500,
      "payment_type"        => Payment::TYPE_TRANSFER,
    }
    Payment.create(h)

    h = {
      "user_id"      => user2_id,
      "amount"       => 200,
      "payment_type" => Payment::TYPE_OUTGOING,
    }
    Payment.create(h)

    # sign in
    http = HTTP::Client.new("localhost", Kemal.config.port)
    result = http.post_form("/sign_in", {"email" => sample_user1_email, "password" => sample_user1_password})
    json = JSON.parse(result.body)
    token = json["token"].to_s

    headers = HTTP::Headers.new
    headers["X-Token"] = token

    # not signed request
    http = HTTP::Client.new("localhost", Kemal.config.port)
    result = http.exec("GET", "/current_user")
    json = JSON.parse(result.body)
    json["id"]?.should eq nil
    json["email"]?.should eq nil

    http = HTTP::Client.new("localhost", Kemal.config.port)
    result = http.exec("GET", "/current_user", headers)
    json = JSON.parse(result.body)
    json["email"].should eq sample_user1_email
    json["handle"].should eq sample_user1_handle

    # get user balance
    http = HTTP::Client.new("localhost", Kemal.config.port)
    result = http.exec("GET", "/balance", headers)
    old_balance = result.body.to_s.to_i
    old_balance.should eq user1.balance

    # create transfer
    json_headers = HTTP::Headers.new
    json_headers["X-Token"] = token
    json_headers["Content-Type"] = "application/json"
    json_headers["Accept"] = "application/json"

    transfer_amount = 10
    http = HTTP::Client.new("localhost", Kemal.config.port)
    params = {"destination_user_id" => user2_id, "amount" => transfer_amount}
    result = http.exec("POST", "/transfer", json_headers, params.to_json)
    json = JSON.parse(result.body)

    # get new user balance
    http = HTTP::Client.new("localhost", Kemal.config.port)
    result = http.exec("GET", "/balance", headers)
    new_balance = result.body.to_s.to_i
    new_balance.should eq user1.balance
    new_balance.should eq (old_balance - transfer_amount)

    # close after
    CrystalInit.stop
  end
end
