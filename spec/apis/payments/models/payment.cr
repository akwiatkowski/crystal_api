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
crystal_resource_convert(payment, Payment)
crystal_resource_migrate(payment, payments, Payment)
crystal_resource_model_methods(payment, payments, Payment)



struct Payment
  TYPE_INCOMING = "incoming"
  TYPE_OUTGOING = "outgoing"
  TYPE_TRANSFER = "transfer"
end
