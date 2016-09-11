class PaymentApi
end

get "/current_user" do |env|
  env.current_user.to_json
end

get "/balance" do |env|
  cu = env.current_user
  if cu["id"]?
    user = User.fetch_one(where: {"id" => cu["id"]})
    user.not_nil!.balance
  else
    nil
  end
end

post "/transfer" do |env|
  cu = env.current_user
  if cu["id"]?
    # current user
    user = User.fetch_one(where: {"id" => cu["id"]}).not_nil!
    balance = user.balance

    amount = env.params.json["amount"].to_s.to_i
    destination_user_id = env.params.json["destination_user_id"].to_s.to_i

    # destination user
    destination_user = User.fetch_one(where: {"id" => destination_user_id}).not_nil!

    h = {
      "user_id"             => user.id,
      "destination_user_id" => destination_user.id,
      "amount"              => amount,
      "created_at"          => Time.now,
      "payment_type"        => Payment::TYPE_TRANSFER,
    }

    payment = Payment.create(h)
    payment.to_json
  else
    nil
  end
end
