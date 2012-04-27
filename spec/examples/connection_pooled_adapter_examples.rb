require 'spec_helper'

shared_examples_for "a connection pooled adapter" do
  context "current_pool_klass" do
    it "should return AR:Base when using default database" do
      subject.stub(:current_database).and_return(config[:database])
      subject.current_pool_klass.should == ActiveRecord::Base
    end

    it "should return dummy class based on database name" do
      subject.stub(:current_database).and_return('some_db')
      subject.current_pool_klass.should == SomeDb
    end
  end


  context "create_connection_pool_klass" do
    let(:database){ Apartment::Test.next_db }

    before { subject.create database }
    after { subject.drop database }

    it "should use default connection spec when none specified" do
      klass = subject.create_connection_pool_klass('AnotherDb')
      klass.connection.pool.spec.config[:database].should == config[:database]
    end

    it "should use specific connection spec when specified" do
      custom = config.clone
      custom[:database] = database
      klass = subject.create_connection_pool_klass('CustomDb', custom)

      Apartment::Database.current_database = database
      klass.connection.pool.spec.config[:database].should == database

      Apartment::Database.current_database = config[:database]
    end

    it "should return active connection for undefined dummy classes" do
      (Module.const_get(undefd_class) rescue nil).should be_nil
      klass = subject.create_connection_pool_klass(undefd_class)
      klass.connection.should be_true
    end

    it "should return active connection for existing dummy classes with no existing pool" do
      #create a class for current db
      klass_name = database.underscore.classify
      klass = Class.new(ActiveRecord::Base) 
      Object.send :remove_const, klass_name.to_sym
      Object.const_set klass_name, klass 

      #clear all connection pools
      Apartment::Database.connection_pools_klasses.each do |klass|
        ActiveRecord::Base.connection_handler.remove_connection(klass.constantize)
      end

      #set current_database manually
      Apartment::Database.current_database = database

      ActiveRecord::Base.connection_handler.connection_pools.empty?.should be_true

      klass = subject.create_connection_pool_klass(klass_name)
      klass.connection.should be_true
    end

  end
end
