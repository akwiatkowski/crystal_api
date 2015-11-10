# crystal_api

Sample application as a structure for REST API written in Crystal.
It does not use ORM instead custom SQL queries.

## Roadmap

- [x] Fix DB mapping to allow create database - add types of columns to definition list
- [ ] Check and fix JSON mapping
- [x] Update action
- [x] Destroy action
- [x] Clean Postgres adapter
- [x] Rewritten for easier usage (less code needed, a small amount of magic)

## Installation

1. Copy `config/database.yml.sample` to `config/database.yml`

   `copy config/database.yml.sample config/database.yml`

2. Change Postgresql user and password in `config/database.yml`

3. Create database if needed accessible via previously set credentials.

4. Create sample table:

```
create table if not exists events (
  id serial,
  name varchar(255),
  primary key(id)
)
```

5. Run `shards install`

6. Run server `crystal bin/api.cr`

## Usage

You have simple REST JSON api server now run on port 8001. Feel free to mess a bit.

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


## Development

TODO: Write development instructions here

## Contributing

1. Fork it ( https://github.com/akwiatkowski/crystal_api/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [akwiatkowski](https://github.com/akwiatkowski) Aleksander Kwiatkowski - creator, maintainer
