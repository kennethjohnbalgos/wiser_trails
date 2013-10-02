require 'wiser_trails/version'
require 'active_support'
require 'action_view'

# +wiser_trails+ keeps track of changes made to models
# and allows you to display them to the users.
#
# Check {WiserTrails::Tracked::ClassMethods#tracked} for more details about customizing and specifying
# ownership to users.

module WiserTrails
  extend ActiveSupport::Concern
  extend ActiveSupport::Autoload

  autoload :Activity,     'wiser_trails/models/activity'
  autoload :Activist,     'wiser_trails/models/activist'
  autoload :Adapter,      'wiser_trails/models/adapter'
  autoload :Trackable,    'wiser_trails/models/trackable'
  autoload :Common
  autoload :Config
  autoload :Creation,     'wiser_trails/actions/creation.rb'
  autoload :Deactivatable,'wiser_trails/roles/deactivatable.rb'
  autoload :Destruction,  'wiser_trails/actions/destruction.rb'
  autoload :Renderable
  autoload :TrailIt,      'wiser_trails/roles/trail_it.rb'
  autoload :Update,       'wiser_trails/actions/update.rb'
  autoload :VERSION

  # Switches WiserTrails on or off.
  # @param value [Boolean]
  # @since 0.5.0
  def self.enabled=(value)
    WiserTrails.config.enabled = value
  end

  # Returns `true` if WiserTrails is on, `false` otherwise.
  # Enabled by default.
  # @return [Boolean]
  # @since 0.5.0
  def self.enabled?
    !!WiserTrails.config.enabled
  end

  def self.config
    @@config ||= WiserTrails::Config.instance
  end

  # Method used to choose which ORM to load
  # when WiserTrails::Activity class is being autoloaded
  def self.inherit_orm(model="Activity")
    orm = WiserTrails.config.orm
    require "wiser_trails/orm/#{orm.to_s}"
    "WiserTrails::ORM::#{orm.to_s.classify}::#{model}".constantize
  end

  # Module to be included in ActiveRecord models. Adds required functionality.
  module Model
    extend ActiveSupport::Concern
    included do
      include Common
      include Deactivatable
      include TrailIt
      include Activist  # optional associations by account|owner
    end
  end
end

require 'wiser_trails/utility/store_controller'
require 'wiser_trails/utility/view_helpers'