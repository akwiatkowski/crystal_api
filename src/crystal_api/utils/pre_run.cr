module Kemal
  class Config
    INITIALIZERS       = [] of Proc(Nil)

    def setup_initializers
      puts INITIALIZERS.size
    end

    def setup
      setup_initializers
      super
    end
  end
end
