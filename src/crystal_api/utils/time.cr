struct Time
  def to_json(io : IO)
    io << self.to_json
  end
end
