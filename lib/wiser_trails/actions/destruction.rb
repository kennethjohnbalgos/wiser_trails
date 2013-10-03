module WiserTrails
  # Handles creation of Activities upon destruction of tracked model.
  module Destruction
    extend ActiveSupport::Concern

    included do
      before_destroy :activity_on_destroy
    end
    private
      # Records an activity upon destruction of the tracked model
      def activity_on_destroy
        activity = create_activity(:destroy, old_value: self.attributes)
        activity.update_attribute(:old_value, self.attributes.stringify_keys) if activity
      end
  end
end
