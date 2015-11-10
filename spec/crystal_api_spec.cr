require "./spec_helper"

describe CrystalApi do
  # TODO: Write tests

  it "works" do
    a = CrystalApi::App.new

    return false    server = HTTP::Server.new(8080, a)
    server.listen

    return false    p = CrystalApi::Pg.new

    t = Time.now.epoch_f
    p.add_event("test")
    puts Time.now.epoch_f - t
  end
end
