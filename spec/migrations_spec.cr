require "./spec_helper"
require "./integration_helper"

describe CrystalMigrations do
  it "create DB, run migration and store info which were executed" do
    cm = CrystalMigrations.new("spec/migrations")
    cm.migrate

    count =  Cat.count.to_s.to_i
    count.should eq 2

    cm.rollback

    count =  Cat.count.to_s.to_i
    count.should eq 0

    cm.migrate

    count =  Cat.count.to_s.to_i
    count.should eq 2

    cm.full_rollback
  end
end
