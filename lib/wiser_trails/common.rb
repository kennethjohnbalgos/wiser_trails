module WiserTrails
  # Happens when creating custom activities without either action or a key.
  class NoKeyProvided < Exception; end

  # Used to smartly transform value from metadata to data.
  # Accepts Symbols, which it will send against context.
  # Accepts Procs, which it will execute with controller and context.
  # @since 0.4.0
  def self.resolve_value(context, thing)
    case thing
    when Symbol
      context.__send__(thing)
    when Proc
      thing.call(WiserTrails.get_controller, context)
    else
      thing
    end
  end

  # Common methods shared across the gem.
  module Common
    extend ActiveSupport::Concern

    included do
      include Trackable
      class_attribute :activity_owner_global, :activity_account_global, :activity_skip_fields_global,
                      :activity_new_value_global, :activity_hooks, :activity_custom_fields_global,
                      :activity_force_fields_global
      set_wiser_trails_class_defaults
    end

    # @!group Global options

    # @!attribute activity_owner_global
    #   Global version of activity owner
    #   @see #activity_owner
    #   @return [Model]

    # @!attribute activity_account_global
    #   Global version of activity recipient
    #   @see #activity_account
    #   @return [Model]

    # @!attribute activity_new_value_global
    #   Global version of activity parameters
    #   @see #activity_new_value
    #   @return [Hash<Symbol, Object>]

    # @!attribute activity_hooks
    #   @return [Hash<Symbol, Proc>]
    #   Hooks/functions that will be used to decide *if* the activity should get
    #   created.
    #
    #   The supported keys are:
    #   * :create
    #   * :update
    #   * :destroy

    # @!endgroup

    # @!group Instance options

    # Set or get parameters that will be passed to {Activity} when saving
    #
    # == Usage:
    #
    #   @article.activity_new_value = {:article_title => @article.title}
    #   @article.save
    #
    # This way you can pass strings that should remain constant, even when model attributes
    # change after creating this {Activity}.
    # @return [Hash<Symbol, Object>]
    attr_accessor :activity_new_value
    @activity_new_value = {}
    attr_accessor :activity_owner
    @activity_owner = nil
    attr_accessor :activity_account
    @activity_account = nil
    attr_accessor :activity_key
    @activity_key = nil
    attr_accessor :activity_custom_fields
    @activity_custom_fields = {}
    attr_accessor :activity_skip_fields_global
    @activity_skip_fields_global = {}
    attr_accessor :activity_force_fields_global
    @activity_force_fields_global = {}

    # @!visibility private
    @@activity_hooks = {}

    # @!endgroup

    # Provides some global methods for every model class.
    module ClassMethods
      #
      # @since 1.0.0
      # @api private
      def set_wiser_trails_class_defaults
        self.activity_owner_global             = nil
        self.activity_account_global           = nil
        self.activity_new_value_global         = {}
        self.activity_hooks                    = {}
        self.activity_custom_fields_global     = {}
        self.activity_skip_fields_global       = {}
        self.activity_force_fields_global      = {}
      end

      def get_hook(key)
        key = key.to_sym
        if self.activity_hooks.has_key?(key) and self.activity_hooks[key].is_a? Proc
          self.activity_hooks[key]
        else
          nil
        end
      end
    end
    #
    # Returns true if WiserTrails is enabled
    # globally and for this class.
    # @return [Boolean]
    # @api private
    # @since 0.5.0
    def wiser_trails_enabled?
      WiserTrails.enabled?
    end
    #
    # Shortcut for {ClassMethods#get_hook}
    # @param (see ClassMethods#get_hook)
    # @return (see ClassMethods#get_hook)
    # @since (see ClassMethods#get_hook)
    # @api (see ClassMethods#get_hook)
    def get_hook(key)
      self.class.get_hook(key)
    end

    # Calls hook safely.
    # If a hook for given action exists, calls it with model (self) and
    # controller (if available, see {StoreController})
    # @param key (see #get_hook)
    # @return [Boolean] if hook exists, it's decision, if there's no hook, true
    # @since 0.4.0
    # @api private
    def call_hook_safe(key)
      hook = self.get_hook(key)
      if hook
        # provides hook with model and controller
        hook.call(self, WiserTrails.get_controller)
      else
        true
      end
    end

    # Directly creates activity record in the database, based on supplied options.
    #
    # It's meant for creating custom activities while *preserving* *all*
    # *configuration* defined before. If you fire up the simplest of options:
    #
    #   current_user.create_activity(:avatar_changed)
    #
    # It will still gather data from any procs or symbols you passed as params
    # to {Tracked::ClassMethods#tracked}. It will ask the hooks you defined
    # whether to really save this activity.
    #
    # But you can also overwrite instance and global settings with your options:
    #
    #   @article.activity :owner => proc {|controller| controller.current_user }
    #   @article.create_activity(:commented_on, :owner => @user)
    #
    # And it's smart! It won't execute your proc, since you've chosen to
    # overwrite instance parameter _:owner_ with @user.
    #
    # [:key]
    #   The key will be generated from either:
    #   * the first parameter you pass that is not a hash (*action*)
    #   * the _:action_ option in the options hash (*action*)
    #   * the _:key_ option in the options hash (it has to be a full key,
    #     including model name)
    #   When you pass an *action* (first two options above), they will be
    #   added to parameterized model name:
    #
    #   Given Article model and instance: @article,
    #
    #     @article.create_activity :commented_on
    #     @article.activities.last.key # => "article.commented_on"
    #
    # For other parameters, see {Tracked#activity}, and "Instance options"
    # accessors at {Tracked}, information on hooks is available at
    # {Tracked::ClassMethods#tracked}.
    # @see #prepare_settings
    # @return [Model, nil] If created successfully, new activity
    # @since 0.4.0
    # @api public
    # @overload create_activity(action, options = {})
    #   @param [Symbol,String] action Name of the action
    #   @param [Hash] options Options with quality higher than instance options
    #     set in {Tracked#activity}
    #   @option options [Activist] :owner Owner
    #   @option options [Activist] :recipient Recipient
    #   @option options [Hash] :params Parameters, see
    #     {WiserTrails.resolve_value}
    # @overload create_activity(options = {})
    #   @param [Hash] options Options with quality higher than instance options
    #     set in {Tracked#activity}
    #   @option options [Symbol,String] :action Name of the action
    #   @option options [String] :key Full key
    #   @option options [Activist] :owner Owner
    #   @option options [Activist] :recipient Recipient
    #   @option options [Hash] :params Parameters, see
    #     {WiserTrails.resolve_value}
    def create_activity(*args)
      return unless self.wiser_trails_enabled?
      options = prepare_settings(*args)

      if call_hook_safe(options[:key].split('.').last)
        reset_activity_instance_options
        return WiserTrails::Adapter.create_activity(self, options)
      end

      nil
    end

    # Prepares settings used during creation of Activity record.
    # params passed directly to tracked model have priority over
    # settings specified in tracked() method
    #
    # @see #create_activity
    # @return [Hash] Settings with preserved options that were passed
    # @api private
    # @overload prepare_settings(action, options = {})
    #   @see #create_activity
    # @overload prepare_settings(options = {})
    #   @see #create_activity
    def prepare_settings(*args)
      # key
      all_options = args.extract_options!
      options = {
        key: all_options.delete(:key),
        action: all_options.delete(:action)
      }
      action = (args.first || options[:action]).try(:to_s)

      options[:key] = extract_key(action, options)

      raise NoKeyProvided, "No key provided for #{self.class.name}" unless options[:key]

      options.delete(:action)

      # user responsible for the activity
      options[:owner] = WiserTrails.resolve_value(self,
        (all_options.has_key?(:owner) ? all_options[:owner] : (
          self.activity_owner || self.class.activity_owner_global
          )
        )
      )

      # recipient of the activity
      options[:account] = WiserTrails.resolve_value(self,
        (all_options.has_key?(:account) ? all_options[:account] : (
          self.activity_account || self.class.activity_account_global
          )
        )
      )

      changes = Hash.new
      self.changed_attributes.each do |attr, val|
        changes[attr.to_sym] = val if attr != "updated_at"
      end
      options[:old_value] = changes.stringify_keys
      options.delete(:params)

      customs = self.class.activity_custom_fields_global.clone
      customs.merge!(self.activity_custom_fields) if self.activity_custom_fields
      customs.merge!(all_options)
      customs.each do  |k, v|
        customs[k] = WiserTrails.resolve_value(self, v)
      end.merge options
    end

    # Helper method to serialize class name into relevant key
    # @return [String] the resulted key
    # @param [Symbol] or [String] the name of the operation to be done on class
    # @param [Hash] options to be used on key generation, defaults to {}
    def extract_key(action, options = {})
      (options[:key] || self.activity_key ||
        ((self.class.name.underscore.gsub('/', '_') + "." + action.to_s) if action)
      ).try(:to_s)
    end

    # Resets all instance options on the object
    # triggered by a successful #create_activity, should not be
    # called from any other place, or from application code.
    # @private
    def reset_activity_instance_options
      @activity_old_value = {}
      @activity_new_value = {}
      @activity_key = nil
      @activity_owner = nil
      @activity_account = nil
      @activity_custom_fields = {}
      @activity_skip_fields_global = {}
      @activity_force_fields_global = {}
    end
  end
end
