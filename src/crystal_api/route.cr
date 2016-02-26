require "kemal/kemal/route"

class CrystalApi::Route < Kemal::Route
  getter handler
  getter method
  getter path
end
