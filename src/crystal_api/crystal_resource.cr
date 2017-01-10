macro crystal_resource(resource_name, resource_table, model_name)
  crystal_resource_convert({{resource_name}}, {{model_name}})
  crystal_resource_migrate({{resource_name}}, {{resource_table}}, {{model_name}})
  crystal_resource_model_methods({{resource_name}}, {{resource_table}}, {{model_name}})
end

macro crystal_resource_convert(resource_name, model_name)
  # TODO rewrite
  # https://github.com/crystal-lang/crystal-db/blob/master/src/db/result_set.cr
  # https://github.com/crystal-lang/crystal-db/blob/master/src/db/mapping.cr
  # https://github.com/will/crystal-pg/blob/800540888edf4012d2fdaba5d508665b462700dc/src/pg/result_set.cr
  # http://crystal-lang.github.io/crystal-db/api/0.3.3/
  # https://crystal-lang.org/docs/database/
  def crystal_resource_convert_{{resource_name}}(db_result)
    fields = db_result.column_names

    resources = Array({{model_name}}).new

    db_result.each do
      # #i = 0
      # #resource = {{model_name}}.new
      # db_result.each_column do
      #   puts db_result.read(type: String).class
      #
      #   #resource.assign(fields[i], db_result.read)
      #   #i += 1
      # end
      #

      resource = {{model_name}}.new(db_result)
      resources << resource
    end

    # fields # => ["id", "name"]
    # db_result.read # => 1
    # db_result.read # => "test"

    #   # resource = {{model_name}}.new(fields, row)
    #   # resources << resource
    #end

    return resources
  end
end

macro crystal_resource_migrate(resource_name, resource_table, model_name)
  # magic migration
  def crystal_migrate_now_{{resource_name}}
    sql = {{model_name}}.create_table_sql("{{resource_table}}")
    handler = Kemal::Config::HANDLERS.select{|h| h.as?(Kemal::CrystalApi)}.first.as(Kemal::CrystalApi)
    service = handler.crystal_service
    result = service.execute_sql(sql)
  end

  def crystal_drop_now_{{resource_name}}
    sql = "drop table if exists {{resource_table}};"
    handler = Kemal::Config::HANDLERS.select{|h| h.as?(Kemal::CrystalApi)}.first.as(Kemal::CrystalApi)
    service = handler.crystal_service
    result = service.execute_sql(sql)
  end

  def crystal_migrate_{{resource_name}}
    CrystalInit::INITIALIZERS << ->{
      crystal_migrate_now_{{resource_name}}
    }
  end

  def crystal_drop_{{resource_name}}
    CrystalInit::INITIALIZERS << ->{
      crystal_drop_now_{{resource_name}}
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

  @@per_page = 25

  def self.service
    CrystalService.instance
  end

  def self.execute_sql(q : String)
    service.execute_sql(q)
  end

  def execute_sql(q : String)
    self.class.execute_sql(q)
  end

  def self.delete_all(
      where : Hash = {} of String => PgType,
      where_sql : String = ""
    )
    service.delete_all(
      collection: "{{resource_table}}",
      where: where,
      where_sql: where_sql
    )
  end

  def self.count(
      where : Hash = {} of String => PgType,
      where_sql : String = ""
    )

    db_result = service.count(
      collection: "{{resource_table}}",
      where: where,
      where_sql: where_sql
    )

    return db_result
  end

  def self.fetch_all(
      where : Hash = {} of String => PgType,
      where_sql : String = "",
      limit : Int32 = 25,
      offset : Int32 = 0,
      order : String = "",
      per_page : Int32 = @@per_page,
      page : Int32 = 0,
    )

    # pagination
    # TODO: first page if page number 1, should it be 0?
    if page > 0
      pagination_limit = per_page
      # pagination cannot fetch more than regular fetch_all
      limit = pagination_limit if limit > 0 && pagination_limit < limit
      offset = (page - 1) * per_page
    end

    db_result = service.fetch_all(
      collection: "{{resource_table}}",
      where: where,
      where_sql: where_sql,
      limit: limit,
      order: order,
      offset: offset
    )
    resources = crystal_resource_convert_{{resource_name}}(db_result)

    return resources
  end

  def self.fetch_one(
      where : Hash = {} of String => PgType,
      where_sql : String = "",
      order : String = ""
    )

    resources = fetch_all(
      where: where,
      where_sql: where_sql,
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
    db_result = service.update_one(
      collection: "{{resource_table}}",
      id: id,
      hash: h
    )
    resources = crystal_resource_convert_{{resource_name}}(db_result)
    if resources.size > 0
      return resources[0]
    else
      return nil
    end
  end

  def update(h : Hash(String, PgType))
    return nil if self.id.nil? # TODO

    return self.class.update(self.id.not_nil!, h)
  end

  def delete
    self.class.service.delete_one("{{resource_table}}", self.id.not_nil!)
  end

  def reload
    return self.class.fetch_one(where: {"id" => self.id})
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
    h = env.params.json["{{resource_name}}"].as(Hash)
    # note: It is not needed now
    # resource = {{model_name}}.new(h)

    db_result = env.crystal_service.insert_into_table("{{resource_table}}", h)
    resources = crystal_resource_convert_{{resource_name}}(db_result)

    if resources.size > 0
      resources.first.to_json
    else
      nil.to_json
    end
  end

  put "/{{resource_path}}/:id" do |env|
    object_id = env.params.url["id"].to_s.to_i
    h = env.params.json["{{resource_name}}"].as(Hash)
    db_result = env.crystal_service.update_one("{{resource_table}}", object_id, h)
    resources = crystal_resource_convert_{{resource_name}}(db_result)

    if resources.size > 0
      resources.first.to_json
    else
      nil.to_json
    end
  end

  delete "/{{resource_path}}/:id" do |env|
    object_id = env.params.url["id"].to_s.to_i
    db_result = env.crystal_service.delete_one("{{resource_table}}", object_id)
    resources = crystal_resource_convert_{{resource_name}}(db_result)

    if resources.size > 0
      resources.first.to_json
    else
      nil.to_json
    end
  end

end
