macro crystal_resource_convert(resource_name, resource_path, resource_table, model_name)
  def crystal_resource_convert_{{resource_name}}(db_result)
    fields = db_result.fields.map{|f| f.name} # Array(String)

    resources = Array({{model_name}}).new
    db_result.rows.each do |row|
      resource = {{model_name}}.new(fields, row)
      resources << resource
    end

    return resources
  end
end

macro crystal_resource_migrate(resource_name, resource_path, resource_table, model_name)
  # magic migration
  def crystal_migrate_{{resource_name}}
    sql = {{model_name}}.create_table_sql("{{resource_table}}")
    handler = Kemal::Config::HANDLERS.select{|h| h.as?(Kemal::CrystalApi)}.first as Kemal::CrystalApi
    service = handler.crystal_service
    result = service.execute_sql(sql)
  end
end



macro crystal_resource(resource_name, resource_path, resource_table, model_name)
  crystal_resource_convert({{resource_name}}, {{resource_path}}, {{resource_table}}, {{model_name}})
  crystal_resource_migrate({{resource_name}}, {{resource_path}}, {{resource_table}}, {{model_name}})

  get "/{{resource_path}}" do |env|
    db_result = env.crystal_service.get_all_objects("{{resource_table}}")
    resources = crystal_resource_convert_{{resource_name}}(db_result)
    resources.to_json
  end

  get "/{{resource_path}}/:id" do |env|
    object_id = env.params.url["id"].to_s.to_i
    db_result = env.crystal_service.get_object("{{resource_table}}", object_id)
    resources = crystal_resource_convert_{{resource_name}}(db_result)

    if resources.size > 0
      resources.first.to_json
    else
      nil.to_json
    end
  end

  post "/{{resource_path}}" do |env|
    h = env.params.json["{{resource_name}}"] as Hash
    # note: It is not needed now
    # resource = {{model_name}}.new(h)

    db_result = env.crystal_service.insert_object("{{resource_table}}", h)
    resources = crystal_resource_convert_{{resource_name}}(db_result)

    if resources.size > 0
      resources.first.to_json
    else
      nil.to_json
    end
  end

  put "/{{resource_path}}/:id" do |env|
    object_id = env.params.url["id"].to_s.to_i
    h = env.params.json["{{resource_name}}"] as Hash
    db_result = env.crystal_service.update_object("{{resource_table}}", object_id, h)
    resources = crystal_resource_convert_{{resource_name}}(db_result)

    if resources.size > 0
      resources.first.to_json
    else
      nil.to_json
    end
  end

  delete "/{{resource_path}}/:id" do |env|
    object_id = env.params.url["id"].to_s.to_i
    db_result = env.crystal_service.delete_object("{{resource_table}}", object_id)
    resources = crystal_resource_convert_{{resource_name}}(db_result)

    if resources.size > 0
      resources.first.to_json
    else
      nil.to_json
    end
  end

end
