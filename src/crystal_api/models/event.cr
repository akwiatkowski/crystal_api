require "json"

class Models::Event
  JSON.mapping({
      id: Int64,
      name: String
    }
  )

  def initialize(h)
    puts h.inspect
  end
end
