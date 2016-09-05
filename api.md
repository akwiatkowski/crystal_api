# API of crystal_api

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
