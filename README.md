# Apartment
*Multitenancy for Rails 3*

Apartment provides tools to help you deal with multiple databases in your Rails
application. If you need to have certain data sequestered based on account or company,
but still allow some data to exist in a common database, Apartment can help.


## Installation

### Rails 3

Add the following to your Gemfile:

    gem 'apartment'

That's all you need to set up the Apartment libraries. If you want to switch databases
on a per-user basis, look under "Usage - Switching databases per request", below.

> NOTE: If using [postgresl schemas](http://www.postgresql.org/docs/9.0/static/ddl-schemas.html) you must use:
>
> * for Rails 3.0.x: _Rails ~> 3.0.10_, it contains a [patch](https://github.com/rails/rails/pull/1607) that has better postgresql schema support
> * for Rails 3.1.x: _Rails ~> 3.1.2_, it contains a [patch](https://github.com/rails/rails/pull/3232) that makes prepared statements work with multiple schemas

## Usage

### Creating new Databases

Before you can switch to a new apartment database, you will need to create it. Whenever
you need to create a new database, you can run the following command:

    Apartment::Database.create('database_name')

Apartment will create a new database in the following format: "_environment_\_database_name".
In the case of a sqlite database, this will be created in your 'db/migrate' folder. With
other databases, the database will be created as a new DB within the system.

When you create a new database, all migrations will be run against that database, so it will be
up to date when create returns.

#### Notes on PostgreSQL

PostgreSQL works slightly differently than other databases when creating a new DB. If you
are using PostgreSQL, Apartment by default will set up a new **schema** and migrate into there. This
provides better performance, and allows Apartment to work on systems like Heroku, which
would not allow a full new database to be created.

One can optionally use the full database creation instead if they want, though this is not recommended

### Switching Databases

To switch databases using Apartment, use the following command:

    Apartment::Database.switch('database_name')

When switch is called, all requests coming to ActiveRecord will be routed to the database
you specify (with the exception of excluded models, see below). To return to the 'root'
database, call switch with no arguments.

### Switching Databases per request

You can have Apartment route to the appropriate database by adding some Rack middleware.
Apartment can support many different "Elevators" that can take care of this routing to your data.
In house, we use the subdomain elevator, which analyzes the subdomain of the request and switches
to a database schema of the same name. It can be used like so:

    # application.rb
    module My Application
      class Application < Rails::Application

        config.middleware.use 'Apartment::Elevators::Subdomain'
      end
    end

## Config

The following config options should be set up in a Rails initializer such as:

    config/initializers/apartment.rb

To set config options, add this to your initializer:

    Apartment.configure do |config|
      # set your options (described below) here
    end

### Excluding models

If you have some models that should always access the 'root' database, you can specify this by configuring
Apartment using `Apartment.configure`.  This will yield a config object for you.  You can set excluded models like so:

    config.excluded_models = ["User", "Company"]        # these models will not be multi-tenanted, but remain in the global (public) namespace

Note that a string representation of the model name is now the standard so that models are properly constantized when reloaded in development

### Handling Environments

By default, when not using postgresql schemas, Apartment will prepend the environment to the database name
to ensure there is no conflict between your environments.  This is mainly for the benefit of your development
and test environments.  If you wish to turn this option off in production, you could do something like:

    config.prepend_environment = !Rails.env.production?

### Managing Migrations

In order to migrate all of your databases (or posgresql schemas) you need to provide a list
of dbs to Apartment.  You can make this dynamic by providing a Proc object to be called on migrations.
This object should yield an array of string representing each database name.  Example:

    # Dynamically get database names to migrate
    config.database_names = lambda{ Customer.select(:database_name).map(&:database_name) }

    # Use a static list of database names for migrate
    config.database_names = ['db1', 'db2']

You can then migration your databases using the rake task:

    rake apartment:migrate

This basically invokes `Apartment::Database.migrate(#{db_name})` for each database name supplied
from `Apartment.database_names`

### Delayed::Job

In order to make ActiveRecord models play nice with DJ and Apartment, include `Apartment::Delayed::Requirements` in any model that is being serialized by DJ.  Also ensure that the `database` attribute (provided by Apartment::Delayed::Requirements) is set on this model *before* it is serialized, to ensure that when it is fetched again, it is done so in the proper Apartment db context.  For example:

    class SomeModel < ActiveRecord::Base
      include Apartment::Delayed::Requirements
    end

    class SomeDJ

      def initialize(model)
        @model = model
        @model.database = Apartment::Database.current_database
      end

      def perform
        # do some stuff
      end
    end

## Development

* The Local setup for development assumes that a root user with no password exists for both mysql and postgresl
* Rake tasks (see the Rakefile) will help you setup your dbs necessary to run tests
* Please issue pull requests to the `development` branch.  All development happens here, master is used for releases
* Setup the test suite:
  * Look at the `spec/config/database.yml.sample`
  * Create the respective databases
  * Create your own `spec/config/database.yml` and match your credentials (don't commit this)
  * Run `rake spec`
* Ensure that your code is accompanied with tests.  No code will be merged without tests

## TODO

* Shared examples for testing to ensure consistency across all adapters
