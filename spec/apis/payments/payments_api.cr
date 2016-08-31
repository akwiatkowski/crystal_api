# require "crystal_api"

require "./models/payment"
require "./models/user"

auth_token_mw = Kemal::AuthToken.new
auth_token_mw.sign_in do |email, password|
  User.sign_in(email, password)
end
auth_token_mw.load_user do |user|
  User.load_user(user)
end

Kemal.config.add_handler(auth_token_mw)
Kemal.config.port = 8002

get "/current_user" do |env|
  env.current_user.to_json
end

get "/balance" do |env|
  cu = env.current_user
  if cu["id"]?
    result = env.crystal_service.get_object("users", cu["id"].to_s.to_i)
    resources = crystal_resource_convert_user(result)
    resources[0].balance
  else
    nil
  end
end

post "/transfer" do |env|
  cu = env.current_user
  if cu["id"]?
    # current user
    result = env.crystal_service.get_object("users", cu["id"].to_s.to_i)
    users = crystal_resource_convert_user(result)
    user = users[0]
    balance = user.balance

    amount = env.params.json["amount"].to_s.to_i
    destination_user_id = env.params.json["destination_user_id"].to_s.to_i

    # destination user
    result = env.crystal_service.get_object("users", destination_user_id)
    users = crystal_resource_convert_user(result)
    destination_user = users[0]

    h = {
      "user_id"             => user.id,
      "destination_user_id" => destination_user.id,
      "amount"              => amount,
      # "created_at" => Time.now,
      "payment_type" => Payment::TYPE_TRANSFER,
    }

    result = env.crystal_service.insert_object("payments", h)
    resources = crystal_resource_convert_payment(result)
    resources[0].to_json
  else
    nil
  end
end
