# Migration responsible for creating a table with trails
class CreateWiserTrails < ActiveRecord::Migration
  # Create table
  def self.up
    create_table :wiser_trails do |t|
      t.belongs_to :trackable, :polymorphic => true
      t.belongs_to :account, :polymorphic => true
      t.belongs_to :owner, :polymorphic => true
      t.string :key
      t.text :old_value
      t.text :new_value

      t.timestamps
    end

    add_index :wiser_trails, [:trackable_id, :trackable_type]
    add_index :wiser_trails, [:account_id, :account_type]
    add_index :wiser_trails, [:owner_id, :owner_type]
  end
  # Drop table
  def self.down
    drop_table :wiser_trails
  end
end