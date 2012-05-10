module Apartment

  module Test

    def self.config
      if File.exists? 'spec/config/database.yml'
        @config ||= YAML.load_file('spec/config/database.yml')
      else
        raise LoadError.new(
          'missing spec/config/database.yml -- use database_example.yml as config guide'
        )
      end
    end

  end

end