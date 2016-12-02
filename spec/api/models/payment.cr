# initialize models
crystal_model(
  Payment,
  id : Int32,
  amount : Int32,
  created_at : Time = Time.now,
  payment_type : String = "incoming_draft",
  user_id : Int32,
  destination_user_id : Int32,
)
crystal_resource(payment, payments, Payment)

crystal_migrate_payment
crystal_clear_table_payment

struct Payment
  TYPE_INCOMING = "incoming"
  TYPE_OUTGOING = "outgoing"
  TYPE_TRANSFER = "transfer"
end
