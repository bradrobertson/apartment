require 'spec_helper'

describe Apartment::Database do
  context "using mysql" do
    # See spec/config/database.yml for configuration parameters

    let(:config){ Apartment::Test.config['connections']['mysql'].symbolize_keys }

    before do
      ActiveRecord::Base.establish_connection config
      Apartment::Test.load_schema   # load the Rails schema in the public db schema
      subject.stub(:config).and_return config   # Use mysql database config for this test
    end

    describe "#adapter" do
      before do
        subject.reload!
      end

      it "should load mysql adapter" do
        subject.adapter
        Apartment::Adapters::Mysql2Adapter.should be_a(Class)
      end

    end
  end

  context "using postgresql" do
    
    # See spec/config/database.yml for configuration parameters
    
    let(:config){ Apartment::Test.config['connections']['postgresql'].symbolize_keys }
    let(:database){ Apartment::Test.next_db }
    let(:database2){ Apartment::Test.next_db }
    
    before do
      Apartment.use_postgres_schemas = true
      ActiveRecord::Base.establish_connection config
      Apartment::Test.load_schema   # load the Rails schema in the public db schema
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
    
    context "with schemas" do
      
      before do
        Apartment.configure do |config|
          config.excluded_models = []
          config.use_postgres_schemas = true
          config.seed_after_create = true
        end
        subject.create database
      end
      
      after{ subject.drop database }
      
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
