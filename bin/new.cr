require "../src/crystal_api"

# define model
crystal_model(User, id : (Int32 | Nil) = nil, name : (String | Nil) = nil, email : (String | Nil) = nil)

#
# u = User.new({"name" => "Name"})
# puts u.inspect
#
# u = User.new({"id" => 2, "name" => "Name"})
# puts u.inspect

# https://github.com/crystal-lang/crystal/blob/204bfd0555921f3aadbda289993cca5323ebaf95/src/macros.cr#L50


crystal_resource user, users, User

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
