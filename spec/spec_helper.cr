require "spec"
require "../src/crystal_api"

# DB connection
$db_yaml_path = "config/travis.yml"
$local_path = "config/database.yml"
$db_yaml_path = $local_path if File.exists?($local_path)

# clear Kemal state every each spec
Spec.after_each do
  Kemal.config.handlers.clear
	Kemal::RouteHandler::INSTANCE.tree = Radix::Tree(Kemal::Route).new
end
