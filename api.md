# API of crystal_api

## Global functions

### Connect to database [REQUIRED]

Configure Kemal Postgresql middleware and adds to middleware stack.
Should be executed at the beginning of application.

```crystal
pg_connect_from_yaml(yaml_file, capacity = 25, timeout = 0.1)
```

* `yaml_file` - path to database configuration file like example below:
* `capacity`
* `timeout`

```yaml
host: localhost
database: crystal
user: crystal_user
password: crystal_password
```

### Define a model

Model is a `struct` used to store and use database row. It is lower level ORM.

```crystal
crystal_model(ModelName, field : (Type | Nil) = nil, ...)
```

* `ModelName` - example: Event, User, Payment
* `field` - name of field, example: id, name, email, created_at
* `Type` - type of data, example: String, Int32

Notes:

* If you want to use `id` you must add `id` as a field.
* Fields need to be hardcoded not fetched from table structure.

Example:

```crystal
crystal_model(EventModel, id : (Int32 | Nil) = nil, name : (String | Nil) = nil)
```

### Full REST JSON API

```crystal
crystal_resource_full_rest(event, events, events, EventModel)
```

## Model

### Model#reload

```crystal
u = User.fetch_one({"id" => 1})
# ...
u = u.reload
```

### Model#update

```crystal
u = User.fetch_one({"id" => 1})
u = u.update({"name" => "New Name"})
u.name
# => "New Name"
```


## Is it ready?

Not yet.
