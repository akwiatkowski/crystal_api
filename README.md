# crystal_api

Toolset for creating REST Api in Crystal Language.

## Roadmap

- [x] Fix DB mapping to allow create database - add types of columns to definition list
- [x] Check and fix JSON mapping
- [x] Update action
- [x] Destroy action
- [x] Clean Postgres adapter
- [x] Rewritten for easier usage (less code needed, a small amount of magic)

## Usage

1. Create empty crystal project:

   `crystal init app crystal_api_sample`

2. Add `crystal_api` to `shard.yml`. Example:

```
name: crystal_api_sample
version: 0.1.0

authors:
  - Crystal Guy <crystal@crystal.org>

dependencies:
  crystal_api:
    github: "akwiatkowski/crystal_api"

license: MIT
```

3. Update shards (Crystal libraries):

   `shards update`

4. Create Postgresql connection file in `config/database.yml` using sample
   from `config/database.yml.sample` from `crystal_api` repository.

```
host: localhost
database: crystal
user: crystal_user
password: crystal_password
```   

5. Set path to Postgresql config file by adding in `src/crystal_api_sample.cr`

```
class CrystalApi::PgAdapter
  def self.config_path
    "config/database.yml"
  end
end
```

6. Create model representing data fetched from Postgresql:

```
class EventModel < CrystalApi::CrystalModel
  def initialize(_db_id, _name)
    @db_id = _db_id as Int32
    @name = _name as (String | Nil)
  end

  getter :db_id, :name

  JSON.mapping({
    "db_id": Int32,
    "name":  String,
  })

  DB_COLUMNS = {
    # "id" is default
    "name" => "varchar(255)",
  }
  DB_TABLE = "events"
end
```

Notes:

* nullable columns must use union with `Nil` class
* all columns should be defined in constructor
* JSON mapping is used when rendereing JSON
* DB_COLUMNS are used when creating table
* DB_TABLE is table name

7. Create service class which performs DB operations.

```
class EventsService < CrystalApi::CrystalService
  def initialize(a)
    @adapter = a
    @table_name = EventModel::DB_TABLE

    # create table if not exists
    create_table(EventModel::DB_COLUMNS)
  end

  def self.from_row(rh)
    return EventModel.new(rh["id"], rh["name"])
  end
end
```

Notes:

* `EventsService.from_row(rh)` instantiates model from Hash-like
  response from DB adapter

8. Create controller class with defined route paths.

```
class EventsController < CrystalApi::CrystalController
  def initialize(s)
    @service = s

    @router = {
      "GET /events"        => "index",
      "GET /events/:id"    => "show",
      "POST /events"       => "create",
      "PUT /events/:id"    => "update",
      "DELETE /events/:id" => "delete",
    }

    @resource_name = "event"
  end
end
```

Notes:

* `@resource_name` is used in `update` and `create`

9. Create app class

```
class ApiApp < CrystalApi::App
  def initialize
    super

    @events_service = EventsService.new(@adapter)
    @events_controller = EventsController.new(@events_service)

    add_controller(@events_controller)

    @port = 8002
  end
end
```

Notes:

* `super` is important
* service and controller must be initialized here and controller must be added
* default port is 8000  

10. You can now run it

```
a = ApiApp.new
a.run
```

## Index

GET http://localhost:8001/events

```
curl -H "Content-Type: application/json" -X GET http://localhost:8001/events
```

## Show

GET http://localhost:8001/events/:id

```
curl -H "Content-Type: application/json" -X GET http://localhost:8001/events/1
```

But first create an Event :)

## Create

POST http://localhost:8001/events

```
curl -H "Content-Type: application/json" -X POST -d '{"event":{"name": "test1"}}' http://localhost:8001/events
```

## Update

PUT http://localhost:8001/events/:id

```
curl -H "Content-Type: application/json" -X PUT -d '{"event":{"name": "test2"}}' http://localhost:8001/events/1
```

## Delete

DELETE http://localhost:8001/events/:id

```
curl -H "Content-Type: application/json" -X DELETE http://localhost:8001/events/1
```


## Contributing

1. Fork it ( https://github.com/akwiatkowski/crystal_api/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [akwiatkowski](https://github.com/akwiatkowski) Aleksander Kwiatkowski - creator, maintainer
