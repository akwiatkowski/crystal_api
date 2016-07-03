require "../src/crystal_api"

pg_connect_from_yaml(File.join(["config", "database.yml"]))

# define model
crystal_model(EventModel, id : (Int32 | Nil) = nil, name : (String | Nil) = nil)
crystal_resource event, events, events, EventModel

# record CrystalApi::CrystalRestController, resource : String, path : String, model_klass : Class

# struct CrystalApi::CrystalRestController
#   @path = "users"
#   @resource = "user"
# end
#
# struct UserController < CrystalApi::CrystalRestController
#   @path = "users"
#   @resource = "user"
# end

# class CrystalApi::CrystalMiddleware < HTTP::Handler
#
#   def call(context)
#     resource_type user, users, User
#
#     call_next context
#   end
# end
#
# class MW < CrystalApi::CrystalMiddleware
# end
#
# cm = MW.new
#
# Kemal.config.add_handler(cm)

Kemal.run
