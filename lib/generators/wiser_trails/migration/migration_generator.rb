require 'generators/wiser_trails'
require 'rails/generators/active_record'

module WiserTrails
  module Generators
    # Migration generator that creates migration file from template
    class MigrationGenerator < ActiveRecord::Generators::Base
      extend Base

      argument :name, :type => :string, :default => 'create_wiser_trails'
      # Create migration in project's folder
      def generate_files
        migration_template 'migration.rb', "db/migrate/#{name}"
      end
    end
  end
end