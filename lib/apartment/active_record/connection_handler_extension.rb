ActiveRecord::ConnectionAdapters::ConnectionHandler.class_eval do
    alias_method :rails_retrieve_connection_pool, :retrieve_connection_pool

    def retrieve_connection_pool(klass)
      unless Apartment.use_postgres_schemas 
        if Apartment.excluded_models.include? klass.name
          klass = ActiveRecord::Base
        elsif Apartment::Database.current_database #and klass != Apartment::Database.current_pool_klass
           klass = Apartment::Database.current_pool_klass
        end
      end

      rails_retrieve_connection_pool(klass)
    end

end
