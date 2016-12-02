# crystal_api

[![Dependency Status](https://shards.rocks/badge/github/akwiatkowski/crystal_api/status.svg)](https://shards.rocks/github/akwiatkowski/crystal_api)
[![devDependency Status](https://shards.rocks/badge/github/akwiatkowski/crystal_api/dev_status.svg)](https://shards.rocks/github/akwiatkowski/crystal_api)
[![Build Status](https://travis-ci.org/akwiatkowski/crystal_api.svg?branch=master)](https://travis-ci.org/akwiatkowski/crystal_api)


`crystal_api` is a set of tools to allow create **very fast** JSON APIs.

Key notes:
* all models are `struct` instead of `class` (like in [active_record.cr](https://github.com/waterlink/active_record.cr))
* custom SQL requests are preferred and encouraged
* but you can use one macro to create all REST (no customization)
* there are some Rails-like methods (coming soon)
* logic need to be customized

**[Sample api explained is here](https://github.com/akwiatkowski/crystal_api/blob/master/payment_api_explained.md)**
**[API - list of all methods (coming soon)](https://github.com/akwiatkowski/crystal_api/blob/master/api.md)**


## Roadmap

- [x] Fix DB mapping to allow create database - add types of columns to definition list
- [x] Check and fix JSON mapping
- [x] Update action
- [x] Destroy action
- [x] Clean Postgres adapter
- [x] Rewrite for easier usage as lib
- [x] JSON response header
- [x] DB inline config (no config file needed)
- [x] [`devise`](https://github.com/plataformatec/devise) compatible sign in controller
- [x] [JWT](https://jwt.io/) request authentication
- [x] Initial rights managament
- [x] Utilize singleton-like approach to get `service`
- [x] Remove `kemal-pg` and use `crystal-pg`
- [ ] Use DB connection pool
- [ ] Use typed queries
- [x] Escape parameters - only quotation characters
- [x] Add `Nil` to field type as union by default - shorter model definition
- [ ] Rename `service` to something better
- [x] Add "scope" method to model Mode.scope({where: Hash, limit: Int32, order: String})
- [ ] Add `page`, `per_page`, `offset`, `random`
- [x] One method for fetching
- [ ] Models should be as much immutable as possible
- [ ] Websockets

## Usage

Please check [spec](https://github.com/akwiatkowski/crystal_api/tree/master/spec) first.

### Fast full REST

```crystal
pg_connect_from_yaml("config/database.yml")

# all fields must be union with Nil
crystal_model(EventModel, id : Int32, name : String)

# magic macro
# crystal_resource_full_rest(<name>, <resource path without '/' >, <DB table name>, <Model struct>)
crystal_resource_full_rest(event, events, events, EventModel)

# create table if not exists
crystal_migrate_event

# set port
Kemal.config.port = 8002
# run, this run migrations before running the HTTP server
CrystalInit.start
```

### Custom API

Please check [short sample](https://github.com/akwiatkowski/crystal_api/tree/master/spec/apis/payments).
This is API for money transfers. User has its account and assigned payments:
incoming (external money transfer), outgoing (user withdraw money), transfer
(user's account money to another user).

### Rails like methods

At this moment I'm refactoring and adding code to easier DB operations.
Readme will be updated after that moment.

## Contributing

1. Fork it ( https://github.com/akwiatkowski/crystal_api/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [akwiatkowski](https://github.com/akwiatkowski) Aleksander Kwiatkowski - creator, maintainer
