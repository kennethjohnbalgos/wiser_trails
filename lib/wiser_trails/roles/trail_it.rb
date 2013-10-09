module WiserTrails
  # Main module extending classes we want to keep track of.
  module TrailIt
    extend ActiveSupport::Concern

    def activity(options = {})
      rest = options.clone
      self.activity_key = rest.delete(:key) if rest[:key]
      self.activity_owner = rest.delete(:owner) if rest[:owner]
      self.activity_new_value = rest.delete(:params) if rest[:params]
      self.activity_account = rest.delete(:recipient) if rest[:recipient]
      self.activity_custom_fields = rest if rest.count > 0
      nil
    end

    # Module with basic +tracked+ method that enables tracking models.
    module ClassMethods
      def trail_it(opts = {})
        options = opts.clone
        all_options = [:create, :update, :destroy]

        self.activity_skip_fields_global = ["updated_at", "created_at"]
        if options[:skip_fields].present?
          self.activity_skip_fields_global += options[:skip_fields]
        end
        options.delete(:skip_fields)

        if options[:force_fields].present?
          self.activity_force_fields_global = options[:skip_fields]
        end
        options.delete(:skip_fields)

        if !options.has_key?(:skip_defaults) && !options[:only] && !options[:except]
          include Creation
          include Destruction
          include Update
        end
        options.delete(:skip_defaults)

        if options[:except]
          options[:only] = all_options - Array(options.delete(:except))
        end

        if options[:only]
          Array(options[:only]).each do |opt|
            if opt.eql?(:create)
              include Creation
            elsif opt.eql?(:destroy)
              include Destruction
            elsif opt.eql?(:update)
              include Update
            end
          end
          options.delete(:only)
        end

        if options[:owner]
          self.activity_owner_global = options.delete(:owner)
        end
        if options[:account]
          self.activity_account_global = options.delete(:account)
        end
        if options.has_key?(:on) and options[:on].is_a? Hash
          self.activity_hooks = options.delete(:on).select {|_, v| v.is_a? Proc}.symbolize_keys
        end

        options.each do |k, v|
          self.activity_custom_fields_global[k] = v
        end

        nil
      end
    end
  end
end
