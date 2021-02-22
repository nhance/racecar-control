require 'active_support/concern'

module TeamNameHelpers
  ORBITS_LAST_NAME_LENGTH  = 30
  ORBITS_FIRST_NAME_LENGTH = 30

  extend ActiveSupport::Concern

  included do
    def driver_name
      last_name
    end

    def driver_name=(name)
      self.last_name = "#{name}"[0..(ORBITS_LAST_NAME_LENGTH - 1)]
      self.last_name = "(#{self.last_name})"
    end

    def team_name
      first_name
    end

    def team_name=(team)
      self.first_name = "#{team}"[0..(ORBITS_FIRST_NAME_LENGTH - 1)]
    end
  end

end
