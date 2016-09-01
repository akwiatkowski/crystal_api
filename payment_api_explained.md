# Payments API explained

This is simple transfer paymnents API. There are users who can sign in and
transfer its money to another user. It is not complete nor 100% safe but
intended only to show how to use `crystal_api`.

```crystal
require "crystal_api"
```

This is required, it is obvious.

```crystal
require "./models/payment"
require "./models/user"
```

I have moved models into separate files. I will explain them now.

## payment.cr

```crystal
# initialize models
crystal_model(
  Payment,
  id : (Int32 | Nil) = nil,
  amount : (Int32 | Nil) = nil,
  created_at : (Time | Nil) = Time.now,
  payment_type : (String | Nil) = "incoming_draft",
  user_id : (Int32 | Nil) = nil,
  destination_user_id : (Int32 | Nil) = nil,
)
```

This macro create models as a `struct`. It is like constant, more efficient
way to store and operate on model.

The first argument `Payment` is the name of model. We will use Rails-like
notation.

The next arguments are model fields. Please use union with `Nil`.

```crystal
crystal_resource(payment, payments, Payment)
```

This macro adds some useful things:

* conversion Postgresql response to model instance - `crystal_resource_convert_payment`
* migration - for example `crystal_migrate_payment` which will run migration if
  the table not exists before running HTTP server
* a lot of model methods like `Payment.fetch_all`, `Payment.create` or `Payment#delete`

```crystal
crystal_migrate_payment
# crystal_clear_table_payment
```

That means it will create DB table if not exists. If you uncomment second line it will execute `delete_all`
before running HTTP server.


```crystal
struct Payment
  TYPE_INCOMING = "incoming"
  TYPE_OUTGOING = "outgoing"
  TYPE_TRANSFER = "transfer"
end
```

These are normal model class constants. You can also add
own methods here just like in next model.

## user.cr

```crystal
require "./payment"
```

Because user's balance is related to `Payment` model we need to require `payment.cr`.

```crystal
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
```

As described in `payment.cr`.

We want to implement JWT for `User` model. That means
we need to create two methods:

* `sign_in` - using email and password check if there is such user in DB
* `load_user` - load user information by using `user_id` information from
   JWT token

These methods must return `UserHash` object. It is special alias of `Hash`.

```crystal
struct User
  # Return id in UserHash if user is signed ok
  def self.sign_in(email : String, password : String) : UserHash

    h = {
      "email"           => email,
      "hashed_password" => Crypto::MD5.hex_digest(password),
    }
```

Passwords are hashed using MD5, feel free to use different way.
`h` is where condition for searching `User` in DB.

```crystal
    # try sign in using handle
    user = User.fetch_one(where: h)
    if user.nil?
      h = {
        "handle"          => email,
        "hashed_password" => Crypto::MD5.hex_digest(password),
      }
      user = User.fetch_one(where: h)
    end
```

If `User` was not found by email let search using handle/nick.

```crystal
    uh = UserHash.new
    if user
      uh["id"] = user.id
    end
    return uh
  end
```

We will put only `User#id` in JWT token.

```crystal
  # Return email and handle if user can be loaded
  def self.load_user(user : Hash) : UserHash
    uh = UserHash.new
    return uh if user["id"].to_s == ""
```

If there is no `User#id` here we cannot do more.

```crystal
    h = {
      "id" => user["id"].to_s.to_i.as(Int32),
    }
    user = User.fetch_one(h)
```

A bit of type casting magic.

```crystal
    if user
      uh["id"] = user.id
      uh["email"] = user.email
      uh["handle"] = user.handle
    end
    return uh
  end
```  

If there is such `User` in DB copy `email`, `handle` and `id`.

```crystal
  private def payment_sql(t : String)
    return "select sum(payments.amount) as sum
    from payments
    where payments.user_id = #{self.id}
    and payments.payment_type = '#{t}';"
  end

  def incoming_payments_amount
    result = execute_sql( payment_sql(Payment::TYPE_INCOMING) )
    amount = result.rows[0][0]

    if amount.nil?
      return 0
    else
      return amount.to_s.to_i32
    end
  end
```

This is `User` instance method using custom SQL code. With some work
API can be much faster if we specify what we need without using
query generation magic.

`outgoing_payments_amount`, `incoming_transfers_amount`, `outgoing_transfers_amount`
are technicaly identical methods. They are needed to calculate current `User`
account balance - `User#balance`.

```crystal
  def balance
    incoming_payments_amount - outgoing_payments_amount + incoming_transfers_amount - outgoing_transfers_amount
  end
end
```

Now we need to tell `kemal` HTTP server that how we want to use JWT.
There is `Kemal::AuthToken` middleware for that.

```crystal
auth_token_mw = Kemal::AuthToken.new
auth_token_mw.sign_in do |email, password|
  User.sign_in(email, password)
end
auth_token_mw.load_user do |user|
  User.load_user(user)
end
Kemal.config.add_handler(auth_token_mw)
```

We create middleware instance, set two methods (`sign_in` and `load_user`)
as was defined before, and add middleware.

```crystal
Kemal.config.port = 8002
```

I prefer to always configure port in case someone forgot the default one.

```crystal
get "/current_user" do |env|
  env.current_user.to_json
end
```

`Kemal::AuthToken` is better described here [kemal-auth-token](https://github.com/akwiatkowski/kemal-auth-token).

```crystal
get "/balance" do |env|
  cu = env.current_user
  if cu["id"]?
    user = User.fetch_one(where: {"id" => cu["id"]})
    user.not_nil!.balance
  else
    nil
  end
end
```

This is the best example of usefulness of `crystal_api` with `kemal-auth-token`.
This piece of code checks if we have `current_user` by JWT token, fetch model
instance and run model instance method `balance` described above.

```crystal
post "/transfer" do |env|
  # (1)
  cu = env.current_user
  if cu["id"]?
    # current user
    user = User.fetch_one(where: {"id" => cu["id"]}).not_nil!

    # (2)
    balance = user.balance
    amount = env.params.json["amount"].to_s.to_i
    destination_user_id = env.params.json["destination_user_id"].to_s.to_i

    # destination user
    destination_user = User.fetch_one(where: {"id" => destination_user_id}).not_nil!

    # (3)
    h = {
      "user_id"             => user.id,
      "destination_user_id" => destination_user.id,
      "amount"              => amount,
      "created_at" => Time.now,
      "payment_type" => Payment::TYPE_TRANSFER,
    }

    payment = Payment.create(h)
    payment.to_json
  else
    nil
  end
end
```

This code should also be easy to understand:

1. Get current user instance.
2. Get POST params into variables with casting. You can add validation not
   allow to transfer more than `current_user#balance` and allow getting
   `destination_user` by searching for `handle`.
3. Create `Payment` model instance.

## How to run it

```crystal
require "./apis/payments/payments_api"

# Yaml structure:
#
# host: localhost
# database: crystal
# user: crystal_user
# password: crystal_password
pg_connect_from_yaml($db_yaml_path)

CrystalInit.start
```

And that is all. Server should be ready, except...

## How to test it

The DB is empty and if you would like to populate it you must
write a bit more code.

```crystal
# run HTTP server spawned in separate thread
CrystalInit.start_spawned_and_wait

# create first user
sample_user1_email = "email1@email.org"
sample_user1_handle = "user1"
sample_user1_password = "password1"

h = {
  "email"           => sample_user1_email,
  "handle"          => sample_user1_handle,
  "hashed_password" => Crypto::MD5.hex_digest(sample_user1_password),
}
user = User.create(h)
```

You should also create second user. There is no register at that moment
but feel free to add it.

```crystal
# create initial payments
h = {
  "user_id"      => user.id,
  "amount"       => 1000,
  "payment_type" => Payment::TYPE_INCOMING,
}
Payment.create(h)
```

That will add some money to user.


```crystal
# sign in
http = HTTP::Client.new("localhost", Kemal.config.port) # or 8002
result = http.post_form("/sign_in", {"email" => sample_user1_email, "password" => sample_user1_password})
json = JSON.parse(result.body)
token = json["token"].to_s
```

You now have JWT token which should be used for all next requests.

```crystal
headers = HTTP::Headers.new
headers["X-Token"] = token
```

You need put token in HTTP headers to authenticate.

```crystal
# get user balance
http = HTTP::Client.new("localhost", Kemal.config.port) # or 8002
result = http.exec("GET", "/balance", headers)
balance = result.body.to_s.to_i
```

This will get current user balance.

```crystal
json_headers = HTTP::Headers.new
json_headers["X-Token"] = token
json_headers["Content-Type"] = "application/json"
json_headers["Accept"] = "application/json"

transfer_amount = 10
http = HTTP::Client.new("localhost", Kemal.config.port)
params = {"destination_user_id" => user2_id, "amount" => transfer_amount}
result = http.exec("POST", "/transfer", json_headers, params.to_json)
json = JSON.parse(result.body)
```

The whole point in this sample API is to allow users to transfer money to each
other. This is sample usage how to do it.

If you want to use `curl` the command should looks like that:

```
curl -H "Content-Type: application/json"  -H "X-Token: <token>" -X POST http://localhost:8002/transfer -d '{"destination_user_id":<user2_id>,"amount":<transfer_amount>}'
```
