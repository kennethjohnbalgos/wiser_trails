module WiserTrails
  # Handles creation of Activities upon destruction and update of tracked model.
  module Creation
    extend ActiveSupport::Concern

    included do
      after_create :activity_on_create
    end
    private
      # Creates activity upon creation of the tracked model
      def activity_on_create
        activity = create_activity(:create, new_value: self.attributes.stringify_keys)
        activity.update_attribute(:old_value, {}) if activity
      end
  end
end
