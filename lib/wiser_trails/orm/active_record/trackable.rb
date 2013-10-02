module WiserTrails
  module ORM
    module ActiveRecord
      # Implements {WiserTrails::Trackable} for ActiveRecord
      # @see WiserTrails::Trackable
      module Trackable
        # Creates an association for activities where self is the *trackable*
        # object.
        def self.extended(base)
          base.has_many :activities, :class_name => "::WiserTrails::Activity", :as => :trackable
        end
      end
    end
  end
end
