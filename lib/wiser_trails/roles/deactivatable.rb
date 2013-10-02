module WiserTrails
  # Enables per-class disabling of WiserTrails functionality.
  module Deactivatable
    extend ActiveSupport::Concern

    included do
      class_attribute :wiser_trails_enabled_for_model
      set_wiser_trails_class_defaults
    end

    # Returns true if WiserTrails is enabled
    # globally and for this class.
    # @return [Boolean]
    # @api private
    # @since 0.5.0
    # overrides the method from Common
    def wiser_trails_enabled?
      WiserTrails.enabled? && self.class.wiser_trails_enabled_for_model
    end

    # Provides global methods to disable or enable WiserTrails on a per-class
    # basis.
    module ClassMethods
      # Switches wiser_trails off for this class
      def wiser_trails_off
        self.wiser_trails_enabled_for_model = false
      end

      # Switches wiser_trails on for this class
      def wiser_trails_on
        self.wiser_trails_enabled_for_model = true
      end

      # @since 1.0.0
      # @api private
      def set_wiser_trails_class_defaults
        super
        self.wiser_trails_enabled_for_model = true
      end
    end
  end
end
