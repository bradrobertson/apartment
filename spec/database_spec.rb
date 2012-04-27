require 'spec_helper'

class SomeDb < ActiveRecord::Base

end

describe Apartment::Database do
  context "using mysql" do
    # See apartment.yml file in dummy app config

    let(:config){ Apartment::Test.config['connections']['mysql'].symbolize_keys }
    let(:undefd_class) { 'MySqlDb' }
    before do
      ActiveRecord::Base.establish_connection config
      Apartment::Test.load_schema   # load the Rails schema in the public db schema
       Apartment.use_postgres_schemas = false
      subject.stub(:config).and_return config   # Use postgresql database config for this test
      subject.reload!
    end

    describe "#adapter" do
      it "should load mysql adapter" do
        subject.adapter
        Apartment::Adapters::Mysql2Adapter.should be_a(Class)
      end

    end

    it_should_behave_like "a connection pooled adapter"

  end

  context "using postgresql" do
    
    # See apartment.yml file in dummy app config
    
    let(:config){ Apartment::Test.config['connections']['postgresql'].symbolize_keys }
    let(:database){ Apartment::Test.next_db }
    let(:database2){ Apartment::Test.next_db }
    
    before do
      Apartment.use_postgres_schemas = false
      ActiveRecord::Base.establish_connection config
      subject.stub(:config).and_return config   # Use postgresql database config for this test
    end
    
    describe "#adapter" do
      before do
        subject.reload!
      end
      
      it "should load postgresql adapter" do
        subject.adapter
        Apartment::Adapters::PostgresqlAdapter.should be_a(Class)
      end
      
      it "should raise exception with invalid adapter specified" do
        subject.stub(:config).and_return config.merge(:adapter => 'unkown')
        
        expect {
          Apartment::Database.adapter
        }.to raise_error
      end
      
    end

    context "with databases" do

      let(:undefd_class) { 'PgDb' }
      before { ActiveRecord::Base.establish_connection config }  

      it_should_behave_like "a connection pooled adapter"
    end

    context "with schemas" do

      before do
        subject.reload!
        Apartment.configure do |config|
          config.excluded_models = []
          config.use_postgres_schemas = true
          config.seed_after_create = true
        end
        Apartment::Test.load_schema 
        subject.create database

        ActiveRecord::Base.establish_connection config
      end
      
      after { subject.drop database }
      
      describe "#create" do
        it "should seed data" do
          subject.switch database
          User.count.should be > 0
        end
      end
    
      describe "#switch" do
        
        let(:x){ rand(3) }
        
        context "creating models" do
          
          before{ subject.create database2 }
          after{ subject.drop database2 }
          
          it "should create a model instance in the current schema" do
            subject.switch database2
            db2_count = User.count + x.times{ User.create }

            subject.switch database
            db_count = User.count + x.times{ User.create }

            subject.switch database2
            User.count.should == db2_count

            subject.switch database
            User.count.should == db_count
          end
        end
        
        context "with excluded models" do
          
          before do
            Apartment.configure do |config|
              config.excluded_models = ["Company"]
            end
            subject.init
          end
          
          it "should create excluded models in public schema" do
            subject.reset # ensure we're on public schema
            count = Company.count + x.times{ Company.create }
            
            subject.switch database
            x.times{ Company.create }
            Company.count.should == count + x
            subject.reset
            Company.count.should == count + x
          end
        end
        
      end
            
    end
    
  end

end
