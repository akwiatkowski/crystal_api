# initialize models
crystal_model(
  Cat,
  id : (Int32 | Nil) = nil,
  name : (Int32 | Nil) = nil,
  color : (Time | Nil) = nil
)
crystal_resource(cat, cats, Cat)
