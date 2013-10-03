module WiserTrails
  module ORM
    # Support for ActiveRecord for WiserTrails. Used by default and supported
    # officialy.
    module ActiveRecord
      # Provides ActiveRecord specific, database-related routines for use by
      # WiserTrails.
      class Adapter
        # Creates the activity on `trackable` with `options`
        def self.create_activity(trackable, options)
          activity = trackable.activities.create options
          activity.update_attribute(:new_value, trackable.attributes.stringify_keys) if activity.new_value == {}
          return activity
        end
      end
    end
  end
end
