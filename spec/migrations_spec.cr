require "./spec_helper"

describe CrystalMigrations do
  it "create DB, run migration and store info which were executed" do
    cm = CrystalMigrations.new("spec/migrations")
    cm.migrate
  end
end
