require "../src/crystal_api"

class DbAdapter < CrystalApi::Adapters::PgAdapter
end

class UserModel < CrystalApi::CrystalModel
  def initialize(_db_id, _name)
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

class UsersService < CrystalApi::CrystalService
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

    @router = {
      "GET /users"     => "index",
      "GET /users/:id" => "show",
    }

    @resource_name = "user"
  end
end

class ApiApp < CrystalApi::App
  def initialize(a)
    super(a)

    @users_service = UsersService.new(@adapter)
    @users_controller = UsersController.new(@users_service)

    add_controller(@users_controller)

    @port = 8001
  end
end

a = ApiApp.new(DbAdapter.new)
a.run
