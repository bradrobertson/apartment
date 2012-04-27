require 'spec_helper'

shared_examples_for "a db based apartment adapter" do
  include Apartment::Spec::AdapterRequirements

  let(:default_database){ subject.process{ ActiveRecord::Base.connection.current_database } }

  describe "#init" do

    before do
      Apartment::Test.reset
      Apartment.configure do |config|
        config.excluded_models = ["Company"]
      end
    end

    it "should process model exclusions" do
      Apartment::Database.init
      Apartment::Database.switch(db1)

      Company.connection.current_database.should == config[:database]
      ActiveRecord::Base.connection.current_database.should == db1
      Company.connection.object_id.should_not == ActiveRecord::Base.connection.object_id
    end
  end

  describe "#drop" do
    it "should raise an error for unknown database" do
      expect {
        subject.drop 'unknown_database'
      }.to raise_error(Apartment::DatabaseNotFound)
    end
  end

  describe "#switch" do
    it "should raise an error if database is invalid" do
      expect {
        subject.switch 'unknown_database'
      }.to raise_error(Apartment::DatabaseNotFound)
    end
  end
end
