macro crystal_resource(resource_name, resource_table, model_name)
  crystal_resource_convert({{resource_name}}, {{model_name}})
  crystal_resource_migrate({{resource_name}}, {{resource_table}}, {{model_name}})
  crystal_resource_model_methods({{resource_name}}, {{resource_table}}, {{model_name}})
end

macro crystal_resource_convert(resource_name, model_name)
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

macro crystal_resource_migrate(resource_name, resource_table, model_name)
  # magic migration
  def crystal_migrate_now_{{resource_name}}
    sql = {{model_name}}.create_table_sql("{{resource_table}}")
    handler = Kemal::Config::HANDLERS.select{|h| h.as?(Kemal::CrystalApi)}.first as Kemal::CrystalApi
    service = handler.crystal_service
    result = service.execute_sql(sql)
  end

  def crystal_migrate_{{resource_name}}
    CrystalInit::INITIALIZERS << ->{
      crystal_migrate_now_{{resource_name}}
    }
  end


    # It is migration style, but require class methods
    # TODO integrate class methods and move to migration
    def crystal_clear_table_now_{{resource_name}}
      {{model_name}}.delete_all
    end

    def crystal_clear_table_{{resource_name}}
      CrystalInit::INITIALIZERS << ->{
        crystal_clear_table_now_{{resource_name}}
      }
    end
end

macro crystal_resource_model_methods(resource_name, resource_table, model_name)
  struct {{model_name}}

  def self.service
    CrystalService.instance
  end

  def self.execute_sql(q : String)
    service.execute_sql(q)
  end

  def execute_sql(q : String)
    self.class.execute_sql(q)
  end

  def self.delete_all
    service.execute_sql("delete from \"{{resource_table}}\";")
  end

  def self.fetch_all(
      where : Hash = {} of String => PgType,
      limit : Int32 = 25,
      order : String = ""
    )

    db_result = service.fetch_all(
      collection: "{{resource_table}}",
      where: where,
      limit: limit,
      order: order
    )
    resources = crystal_resource_convert_{{resource_name}}(db_result)

    return resources
  end

  def self.fetch_one(
      where : Hash = {} of String => PgType,
      order : String = ""
    )

    resources = fetch_all(
      where: where,
      limit: 1,
      order: order
    )

    if resources.size > 0
      return resources[0]
    else
      return nil
    end
  end

  def self.create(h : Hash(String, PgType))
    db_result = service.insert_into_table(
      collection: "{{resource_table}}",
      hash: h
    )
    resources = crystal_resource_convert_{{resource_name}}(db_result)
    if resources.size > 0
      return resources[0]
    else
      return nil
    end
  end


  def self.update(id : Int32, h : Hash(String, PgType))
  end


  def delete
    self.class.service.delete_object("{{resource_table}}", self.id)
  end



end

end

macro crystal_resource_full_rest(resource_name, resource_path, resource_table, model_name)
  crystal_resource_convert({{resource_name}}, {{model_name}})
  crystal_resource_migrate({{resource_name}}, {{resource_table}}, {{model_name}})
  crystal_resource_model_methods({{resource_name}}, {{resource_table}}, {{model_name}})

  get "/{{resource_path}}" do |env|
    db_result = env.crystal_service.fetch_all("{{resource_table}}", limit: 0)
    resources = crystal_resource_convert_{{resource_name}}(db_result)
    resources.to_json
  end

  get "/{{resource_path}}/:id" do |env|
    object_id = env.params.url["id"].to_s.to_i
    db_result = env.crystal_service.fetch_one("{{resource_table}}", where: {"id" => object_id})
    resources = crystal_resource_convert_{{resource_name}}(db_result)
    if resources.size > 0
      resources[0].to_json
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
