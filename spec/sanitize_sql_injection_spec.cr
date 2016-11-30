require "./spec_helper"

describe CrystalService do
  it "escape simple quotation" do
    # I don't know how to test it better
    CrystalService.escape_string("cat").should eq "cat"
    CrystalService.escape_string("cat \" or NULL").should eq "cat \\\" or NULL"
    CrystalService.escape_string("cat \' or NULL").should eq "cat \\\' or NULL"
    CrystalService.escape_string("cat \"; DROP DATABASE bad_bad_tabase; --").should eq "cat \\\"; DROP DATABASE bad_bad_tabase; --"
  end
end
