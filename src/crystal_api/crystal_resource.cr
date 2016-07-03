macro crystal_resource(resource_name, resource_path, resource_table, model_name)
  def crystal_resource_convert_{{resource_name}}(db_result)
    fields = db_result.fields.map{|f| f.name} # Array(String)

    resources = Array({{model_name}}).new
    db_result.rows.each do |row|
      resource = {{model_name}}.new(fields, row)
      resources << resource
    end

    return resources
  end

  get "/{{resource_path}}" do |env|
    db_result = env.crystal_service.get_all_objects("{{resource_table}}")
    resources = crystal_resource_convert_{{resource_name}}(db_result)
    resources.to_json
  end

  get "/{{resource_path}}/:id" do |env|
    resources = Array({{model_name}}).new
    resource = {{model_name}}.new(name: "a", id: 1)
    resources << resource

    resources.to_json
  end


end
