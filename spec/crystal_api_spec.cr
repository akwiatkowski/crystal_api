require "./spec_helper"

describe CrystalApi do
  it "run server " do
    a = CrystalApi::Adapters::PgAdapter.new(config_path: File.join(["config", "database.yml"]))
    c = CrystalApi::App.new(a)
    c.start
  end
end
