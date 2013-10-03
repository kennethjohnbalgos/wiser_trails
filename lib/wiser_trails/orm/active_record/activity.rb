module WiserTrails
  module ORM
    module ActiveRecord
      # The ActiveRecord model containing
      # details about recorded activity.
      class Activity < ::ActiveRecord::Base
        self.table_name = "wiser_trails"
        include Renderable

        # Define polymorphic association to the parent
        belongs_to :trackable, :polymorphic => true
        # Define ownership to a resource responsible for this activity
        belongs_to :owner, :polymorphic => true
        # Define ownership to a resource targeted by this activity
        belongs_to :account, :polymorphic => true
        # Serialize parameters Hash
        serialize :old_value, Hash
        serialize :new_value, Hash

        if ::ActiveRecord::VERSION::MAJOR < 4
          attr_accessible :key, :owner, :account, :trackable, :old_value, :new_value
        end
      end
    end
  end
end