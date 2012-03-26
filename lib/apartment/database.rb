require 'active_support/core_ext/module/delegation'

module Apartment

  #   The main entry point to Apartment functions
  module Database

    extend self

    delegate :create, :current_database, :current_database=, :drop, :process, :process_excluded_models, :reset, :seed, :switch, :to => :adapter

    #   Initialize Apartment config options such as excluded_models
    #
    def init
      process_excluded_models
    end

    #   Fetch the proper multi-tenant adapter based on Rails config
    #
    #   @return {subclass of Apartment::AbstractAdapter}
    #
    def adapter
      @adapter ||= begin
        adapter_method = "#{config[:adapter]}_adapter"

        begin
          require "apartment/adapters/#{adapter_method}"
        rescue LoadError
          raise "The adapter `#{config[:adapter]}` is not yet supported"
        end

        unless respond_to?(adapter_method)
          raise AdapterNotFound, "database configuration specifies nonexistent #{config[:adapter]} adapter"
        end

        send(adapter_method, config)
      end
    end

    #   Reset config and adapter so they are regenerated
    #
    def reload!
      @adapter = nil
      @config = nil
    end

    #   Get class to use as key for ActiveRecord connection pool
    #
    def current_pool_klass

      if current_database == config[:database]
        ActiveRecord::Base
      else
        current_database.underscore.classify.constantize
      end
    end

    #   Create dummy AR class for connection pool key
    #
    def create_connection_pool_klass(klass_name, spec=nil)
      spec ||= config

      unless klass = (Module.const_get(klass_name) rescue nil)
        klass = Class.new(ActiveRecord::Base) 
        Object.const_set klass_name, klass 

        #establish connection here, so it's done only once
        #preserving the connection pool
        klass.establish_connection(spec)
      else
        #ensure connection pools exists for the class 
        #if not create one (normally only hit while changing adapters)
        unless connection_pools_klasses.include?(klass_name)
          klass.establish_connection(spec)
        end
      end

      klass
    end

    #   Retrieve current classes used by connection pools
    #
    def connection_pools_klasses
      #Rails 3.2 & (probably 4.0)
      pools = ActiveRecord::Base.connection_handler.instance_variable_get('@class_to_pool')

      #Rails 3.1
      pools ||= ActiveRecord::Base.connection_handler.instance_variable_get('@connection_pools')

      return pools.keys
    end
  private

    #   Fetch the rails database configuration
    #
    def config
      @config ||= Rails.configuration.database_configuration[Rails.env].symbolize_keys
    end

  end

end
