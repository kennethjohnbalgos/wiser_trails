module WiserTrails
  # Provides helper methods for selecting activities from a user.
  module Activist
    # Delegates to configured ORM.
    def self.included(base)
      base.extend WiserTrails::inherit_orm("Activist")
    end
  end
end