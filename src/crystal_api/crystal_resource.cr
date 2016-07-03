macro crystal_resource(resource_name, resource_path, model_name)
  get "/{{resource_path}}" do |env|
    resources = Array({{model_name}}).new
    resource = {{model_name}}.new(name: "a", id: 1)
    resources << resource

    resources.to_json
  end

  get "/{{resource_path}}/:id" do |env|
    resources = Array({{model_name}}).new
    resource = {{model_name}}.new(name: "a", id: 1)
    resources << resource

    resources.to_json
  end


end
