module WiserTrails
  # Handles creation of Activities upon destruction and update of tracked model.
  module Update
    extend ActiveSupport::Concern

    included do
      before_update :initialize_activity
      after_update :activity_on_update
    end
    private
      # Creates activity upon modification of the tracked model
      def initialize_activity
        create_activity(:update) if self.changed_attributes.except("updated_at").count > 0
      end
      def activity_on_update
        if self.changed_attributes.except("updated_at").count > 0
          activity = Activity.where(trackable_id: self.id, trackable_type: self.class, key: "#{self.class.to_s.downcase}.update").last
          activity.update_attribute(:new_value, activity.trackable.attributes.stringify_keys) if activity
        end
      end
  end
end
