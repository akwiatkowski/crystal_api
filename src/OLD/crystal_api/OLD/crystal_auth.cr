require "radix"

require "./controllers/devise_session_controller"
require "./context"

class CrystalApi::CrystalAuth
  ROLES = {
    "nil":     0,  # not signed user
    "regular": 1,  # every signed
    "admin":   10, # with role 'admin'
  }

  property :proc

  def initialize
    # @proc = -> (context : HTTP::Server::Context, auth : CrystalApi::CrystalAuth ) { true }
    @tree = Radix::Tree(String).new
  end

  def auth_context(context : HTTP::Server::Context)
    return true
    # return @proc.call(context, self)
  end

  def can!(method, path, user_role : String)
    if ROLES.has_key?(user_role)
      add_to_radix_tree(method, path, user_role)
    end
  end

  def can?(context, user_role)
    if ROLES.has_key?(user_role)
      lookup = @tree.find(radix_path(context.request.override_method.as(String), context.request.path))
      # not found ability
      return false unless lookup.found?

      required_role = lookup.payload.as(String)
      if ROLES[required_role] > ROLES[user_role]
        # higher role is required
        return false
      else
        # access granted
        return true
      end
    else
      # no correct user_role provided
      return false
    end
  end

  private def radix_path(method : String, path)
    "/#{method.downcase}#{path}"
  end

  private def add_to_radix_tree(method, path, role)
    node = radix_path(method, path)
    @tree.add(node, role)
  end
end
