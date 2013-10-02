require 'generators/wiser_date'
require 'rails/generators/active_record'

module WiserTrails
  module Generators
    # Activity generator that creates activity model file from template
    class ActivityGenerator < ActiveRecord::Generators::Base
      extend Base

      argument :name, :type => :string, :default => 'wiser_trails'
      # Create model in project's folder
      def generate_files
        copy_file 'model.rb', "app/models/#{name}.rb"
      end
    end
  end
end