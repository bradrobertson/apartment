require 'spec_helper'

describe "ActiveRecord::ConnectionAdapters::ConnectionHandler" do

  context "when switching connections" do
    let(:config){ Apartment::Test.config['connections']['mysql'].symbolize_keys }
    let(:database){ Apartment::Test.next_db }
    let(:database2){ Apartment::Test.next_db }

    before do
      Apartment.use_postgres_schemas = false
      Apartment::Database.stub(:config).and_return config
      Apartment::Database.reload!

      Apartment::Database.connection_pools_klasses.each do |klass|
        ActiveRecord::Base.connection_handler.remove_connection(klass.constantize)
      end

      Apartment::Database.create database
      Apartment::Database.create database2
    end

    after do
      Apartment::Database.reset
      Apartment::Database.drop database 
      Apartment::Database.drop database2
    end
    it "connection pool should be reused when connecting to the same database multiple times" do


      #connect to target db
      Apartment::Database.switch(database)
      db1_pool = ActiveRecord::Base.connection.pool.object_id
      db1_conn = ActiveRecord::Base.connection.object_id

      #connect to second db
      Apartment::Database.switch(database2)

      #reconnect to target db
      Apartment::Database.switch(database)

      db1_conn.should == ActiveRecord::Base.connection.object_id
      db1_pool.should == ActiveRecord::Base.connection.pool.object_id

    end
  end
end
