module Apartment
  module Spec

    #
    #   Define the interface methods required to
    #   use an adapter shared example
    #
    #
    module AdapterRequirements
      
      extend ActiveSupport::Concern
      
      included do
        let(:db1){ Apartment::Test.next_db }
        let(:db2){ Apartment::Test.next_db }
        let(:connection){ ActiveRecord::Base.connection }

        before do
          ActiveRecord::Base.establish_connection config
          subject.create(db1) rescue true
          subject.create(db2) rescue true
        end

        after do
          # Reset before dropping (can't drop a db you're connected to)
          subject.reset

          # sometimes we manually drop these schemas in testing, don't care if we can't drop, hence rescue
          subject.drop(db1) rescue true
          subject.drop(db2) rescue true
          
          Apartment::Database.reload!
        end
      end

      %w{subject config database_names default_database}.each do |method|
        define_method method do
          raise "You must define a `#{method}` method in your host group"
        end unless defined?(method)
      end
      
    end
  end
end
