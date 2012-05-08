require 'bundler' rescue 'You must `gem install bundler` and `bundle install` to run rake tasks'
Bundler.setup
Bundler::GemHelper.install_tasks

require "rspec"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec => "db:test:prepare") do |spec|
  spec.pattern = "spec/**/*_spec.rb"
  # spec.rspec_opts = '--order rand:16996'
end

namespace :spec do

  [:tasks, :unit, :adapters, :integration].each do |type|
    RSpec::Core::RakeTask.new(type => :spec) do |spec|
      spec.pattern = "spec/#{type}/**/*_spec.rb"
    end
  end

end

task :default => :spec

namespace :db do
  namespace :test do
    task :prepare => %w{postgres:drop_db postgres:build_db mysql:drop_db mysql:build_db}
  end
end

namespace :postgres do
  require 'active_record'
  require "#{File.join(File.dirname(__FILE__), 'spec', 'support', 'config')}"

  desc 'Build the PostgreSQL test databases'
  task :build_db do
    build_database('postgresql')
  end

  desc "drop the PostgreSQL test database"
  task :drop_db do
    drop_database('postgresql')
  end

end

namespace :mysql do
  require 'active_record'
  require "#{File.join(File.dirname(__FILE__), 'spec', 'support', 'config')}"

  desc 'Build the MySQL test databases'
  task :build_db do
    build_database('mysql')
  end

  desc "drop the MySQL test database"
  task :drop_db do
    drop_database('mysql')
  end

end

# Builds & migrates database using the given configuration, dropping any old versions.
def build_database(config_name)
  puts "creating database #{config[config_name]['database']}"
    c = admin_connection(config_name)
    c.drop_database config[config_name]['database'] rescue nil
    c.create_database config[config_name]['database']
    ActiveRecord::Base.establish_connection config[config_name]
    ActiveRecord::Migrator.migrate('spec/dummy/db/migrate')
end

# Drops database using the given configuration, failing silently if it doesn't exist.
def drop_database(config_name)
  puts "dropping database #{config[config_name]['database']}"
  c = admin_connection(config_name)
  c.drop_database config[config_name]['database'] rescue nil
end

# Get connection to admin-level schema (for manipulating other schema).
def admin_connection(config_name)
  ActiveRecord::Base.establish_connection config[config_name].merge(
    'database' => config[config_name]['admin_schema']
  )
  ActiveRecord::Base.connection
end

# Return database configurations as given in spec/config/database.yml
def config
  Apartment::Test.config['connections']
end
