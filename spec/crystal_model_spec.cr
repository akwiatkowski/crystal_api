require "./spec_helper"

crystal_model(Payment, id : (Int32 | Nil) = nil, amount : (Int32 | Nil) = 0, created_at : (Time | Nil) = Time.now)

describe CrystalApi do
  it "generate model struct" do
    p = Payment.new
  end
end
