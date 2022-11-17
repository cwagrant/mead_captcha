module Mead
  class Configuration
    attr_accessor :protect_controller_actions, :ignore_controller_actions

    def initialize
      @protect_controller_actions = nil
      @ignore_controller_actions = nil
    end
  end
end
