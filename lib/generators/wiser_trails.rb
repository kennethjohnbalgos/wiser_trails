require 'rails/generators/named_base'

module WiserTrails
  module Generators
    module Base
      # Get path for migration template
      def source_root
        @_wiser_trails_source_root ||= File.expand_path(File.join('../wiser_trails', generator_name, 'templates'), __FILE__)
      end
    end
  end
end