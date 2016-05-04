# crystal_api

[![Build Status](https://travis-ci.org/akwiatkowski/crystal_api.svg?branch=master)](https://travis-ci.org/akwiatkowski/crystal_api)

Toolset for creating REST Api in Crystal Language.

[![Dependency Status](https://shards.rocks/badge/github/akwiatkowski/crystal_api/status.svg)](https://shards.rocks/github/akwiatkowski/crystal_api)
[![devDependency Status](https://shards.rocks/badge/github/akwiatkowski/crystal_api/dev_status.svg)](https://shards.rocks/github/akwiatkowski/crystal_api)

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
- [ ] Other DB engines (partially refactored)
- [ ] More predefined/sample controllers
- [ ] Websockets

## Usage

1. Create empty crystal project:

    `crystal init app crystal_api_sample`

2. Add `crystal_api` to `shard.yml`. Example:

    ```Yaml
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

4.  Configure database (PostgreSQL) access and create `CrystalApi::App` instance.

    * inline:

      ```Crystal
      a = CrystalApi::App.new( DbAdapter.new(user: "crystal_user", password: "crystal_password", database: "crystal", host: "localhost") )
      ```


    * by config file

      Create Postgresql connection file in `config/database.yml` using sample
      from `config/database.yml.sample` from `crystal_api` repository.

      ```Yaml
      host: localhost
      database: crystal
      user: crystal_user
      password: crystal_password
      ```   

      And set path to Postgresql config file by adding in `src/crystal_api_sample.cr`

      ```Crystal
      a = CrystalApi::App.new( DbAdapter.new(config_path: "config/database.yml") )
      ```

5. Create model representing data fetched from Postgresql:

    ```Crystal
    class EventModel < CrystalApi::CrystalModel
      def initialize(_db_id, _name)
        @db_id = _db_id as Int32
        @name = _name as (String | Nil)
      end

      getter :db_id, :name

      JSON.mapping({
        "db_id": Int32,
        "name": (String | Nil),
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
    * all columns should be defined in constructor, which will be utilized in `Service` class
    * JSON mapping is used when rendereing JSON
    * DB_COLUMNS are used only when creating table
    * DB_TABLE is the database table name

6. Create service class which performs DB operations.

    ```Crystal
    class EventsService < CrystalApi::RestService
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

7. Create controller class with defined list of actions and REST path.

    ```Crystal
    class EventsController < CrystalApi::CrystalApi::Controllers::JsonRestApiController
      def initialize(s)
        @service = s

        @actions = [
          "index",
          "show",
          "create",
          "update",
          "delete"
        ]

        @path = "/events"
        @resource_name = "event"
      end
    end
    ```

    Notes:

    * `@resource_name` is used in `update` and `create`
    * `@path` deteremine all endpoints path

8. Create and run app

    ```Crystal
    # a = CrystalApi::App.new(DbAdapter.new(...))
    # it is already defined
    a.port = 8002
    a.add_controller( EventsController.new(EventsService.new(a.adapter)) )
    a.start
    ```


## Index

GET http://localhost:8002/events

```Bash
curl -H "Content-Type: application/json" -X GET http://localhost:8002/events
```

## Show

GET http://localhost:8002/events/:id

```Bash
curl -H "Content-Type: application/json" -X GET http://localhost:8002/events/1
```

But first create an Event :)

## Create

POST http://localhost:8002/events

```Bash
curl -H "Content-Type: application/json" -X POST -d '{"event":{"name": "test1"}}' http://localhost:8002/events
```

## Update

PUT http://localhost:8002/events/:id

```Bash
curl -H "Content-Type: application/json" -X PUT -d '{"event":{"name": "test2"}}' http://localhost:8002/events/1
```

## Delete

DELETE http://localhost:8002/events/:id

```Bash
curl -H "Content-Type: application/json" -X DELETE http://localhost:8002/events/1
```

## Devise sign in, authentication and authorization

```Crystal
require "crystal_api"

class DbAdapter < CrystalApi::Adapters::PgAdapter
end

class UserModel < CrystalApi::CrystalModel
  def initialize(_db_id, _email)
    @db_id = _db_id as Int32
    @email = _email as String
  end

  getter :db_id, :email

  JSON.mapping({
    "db_id": Int32,
    "email": String,
  })

  DB_COLUMNS = {
    # "id" is default
    "email" => "text",
  }
  DB_TABLE = "users"
end

class UsersService < CrystalApi::RestService
  def initialize(a)
    @adapter = a
    @table_name = UserModel::DB_TABLE
  end

  def self.from_row(rh)
    return UserModel.new(rh["id"], rh["email"])
  end
end

class UsersController < CrystalApi::Controllers::JsonRestApiController
  def initialize(s)
    @service = s

    @actions = [
      "index",
      "show",
      "create",
      "update",
      "delete"
    ]

    @path = "/users"
    @resource_name = "user"
  end
end

class SessionService < CrystalApi::DeviseSessionService
  def initialize(a)
    @adapter = a
    @table_name = UserModel::DB_TABLE
  end

  def self.from_row(rh)
    return UserModel.new(rh["id"], rh["email"])
  end
end
```

This part is similar as described above.

```Crystal
class SessionController < CrystalApi::Controllers::DeviseSessionApiController
  # def initialize(s, secret_key = SecureRandom.hex)
  #   @service = s
  #   @path = "/session"
  #   @resource_name = "user"
  # end
end
```

`CrystalApi::Controllers::DeviseSessionApiController` allow to sign in just like
`Rails` `devise` gem. It will return `JWT` token.

```Crystal
a = CrystalApi::App.new(DbAdapter.new(...))
a.port = 8002
a.add_controller( UsersController.new(UsersService.new(a.adapter)) )

secret_key = "secret"
session_controller = SessionController.new(SessionService.new(a.adapter), secret_key: secret_key)
```

You can provide `secret_key` the way you would like, but you can leave it.
In that case `secret_key` will be random generated everytime you will start server.

```Crystal
a.add_controller(session_controller)
```

As every `Controller` you have to add it.

```Crystal
a.auth.can!("GET", "/users/:id", "regular")
```

In this example we want to allow signed user to have access only on this
endpoint. If you want to add access to not signed users add line below.

```Crystal
a.auth.can!("GET", "/users/:id", "nil")
```

Next few line are not so beautiful, but they link sign in `SessionController`
with `CrystalApi::AuthRouteHandler`.

```Crystal
a.auth.proc = -> (context : HTTP::Server::Context, auth : CrystalApi::CrystalAuth) {
  # to allow sign in of not signed users
  if context.request.path == "/session"
    return true
  end

  if context.params.has_key?("token")
    user = session_controller.token_to_user(context.params["token"].to_s)
    if user
      return auth.can?(context, "regular")
    else
      return auth.can?(context, "nil")
    end
  end

  return false
}
```

This move authorization logic into `CrystalApi::AuthRouteHandler`.

```Crystal
a.start
```

Now you can start application, and test it.

```Bash
curl -H "Content-Type: application/json" -X POST -d '{"user":{"email": "email@email.org", "password": "password"}}' http://localhost:8002/session
```

Which will return:

```Json
{"token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo2Mjg5fQ.s4njjtCl1Ch2K_5RJn-9lsNbr49bUWlmcJOAllP5GNI"}
```

And now you can make authenticated API calls:

```Bash
curl -H "Content-Type: application/json" -X GET -d '{"token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo2Mjg5fQ.s4njjtCl1Ch2K_5RJn-9lsNbr49bUWlmcJOAllP5GNI"}' http://localhost:8002/users/1
```

Which returns:

```Json
{"db_id":1,"email":"admin@domain.org"}
```

When you try not to provide correct token:

```Bash
curl -H "Content-Type: application/json" -X GET -d '{"token":"wrong_token"}' http://localhost:8002/users/1
```

You will have an error with 403 forbidden HTTP status:

```
{"error": "forbidden"}
```

## Contributing

1. Fork it ( https://github.com/akwiatkowski/crystal_api/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [akwiatkowski](https://github.com/akwiatkowski) Aleksander Kwiatkowski - creator, maintainer
