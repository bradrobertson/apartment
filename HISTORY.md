# 0.13.0
  * Oct 25, 2011

  - `process` will now rescue with reset if the previous schema/db is no longer available
  - `create` now takes an optional block which allows you to process within the newly created db
  - Fixed Rails version >= 3.0.10 and < 3.1 because there have been significant testing problems with 3.1, next version will hopefully fix this

# 0.12.0
  * Oct 4, 2011
  - Added a `drop` method for removing databases/schemas
  - Refactored abstract adapter to further remove duplication in concrete implementations
  - Excluded models now take string references so they are properly reloaded in development
  - Better silencing of `schema.rb` loading using `verbose` flag

# 0.11.1
  * Sep 22, 2011

  - Better use of Railties for initializing apartment
  - The following changes were necessary as I haven't figured out how to properly hook into Rails reloading
    - Added reloader middleware in development to init Apartment on each request
    - Override `reload!` in console to also init Apartment

# 0.11.0
  * Sep 20, 2011

  - Excluded models no longer use a different connection when using postgresql schemas.  Instead their table_name is prefixed with `public.`

# 0.10.3
  * Sep 20, 2011

  - Fix improper raising of exceptions on create and reset

# 0.10.2
  * Sep 15, 2011

  - Remove all the annoying logging for loading db schema and seeding on create

# 0.10.1
  * Aug 11, 2011

  - Fixed bug in DJ where new objects (that hadn't been pulled from the db) didn't have the proper database assigned

# 0.10.0
  * July 29, 2011

  - Added better support for Delayed Job
  - New config option that enables Delayed Job wrappers
  - Note that DJ support uses a work-around in order to get queues stored in the public schema, not sure why it doesn't work out of the box, will look into it, until then, see documentation on queue'ng jobs

# 0.9.2
  * July 4, 2011

  - Migrations now run associated rails migration fully, fixes schema.rb not being reloaded after migrations

# 0.9.1
  * June 24, 2011

  - Hooks now take the payload object as an argument to fetch the proper db for DJ hooks

# 0.9.0
  * June 23, 2011

  - Added module to provide delayed job hooks

# 0.8.0
  * June 23, 2011

  - Added #current_database which will return the current database (or schema) name

# 0.7.0
  * June 22, 2011

  - Added apartment:seed rake task for seeding all dbs

# 0.6.0
  * June 21, 2011

  - Added #process to connect to new db, perform operations, then ensure a reset

# 0.5.1
  * June 21, 2011

  - Fixed db migrate up/down/rollback
  - added db:redo

# 0.5.0
  * June 20, 2011

  - Added the concept of an "Elevator", a rack based strategy for db switching
  - Added the Subdomain Elevator middleware to enabled db switching based on subdomain

# 0.4.0
  * June 14, 2011

  - Added `configure` method on Apartment instead of using yml file, allows for dynamic setting of db names to migrate for rake task
  - Added `seed_after_create` config option to import seed data to new db on create

# 0.3.0
  * June 10, 2011

  - Added full support for database migration
  - Added in method to establish new connection for excluded models on startup rather than on each switch

# 0.2.0
  * June 6, 2011 *

  - Refactor to use more rails/active_support functionality
  - Refactor config to lazily load apartment.yml if exists
  - Remove OStruct and just use hashes for fetching methods
  - Added schema load on create instead of migrating from scratch

# 0.1.3
  * March 30, 2011 *

  - Original pass from Ryan
