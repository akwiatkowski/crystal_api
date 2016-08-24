require "json"

macro crystal_model(name, *properties)
  struct {{name.id}}
    {% for property in properties %}
      getter {{property.var}} : {{property.type}}
    {% end %}

    JSON.mapping(
    {% for property in properties %}
      {{property.var}}: {{property.type}},
    {% end %}
    )

    COLUMNS = [
      {% for property in properties %}
        {{property.var}},
      {% end %}
    ]

    def initialize({{
                     *properties.map do |field|
                       "@#{field.id}".id
                     end
                   }})
    end

    def initialize(h : Hash)
      {% for property in properties %}
        if h["{{property.var}}"]?
          if h["{{property.var}}"].as?( ({{property.type}}) )
            self.{{property.var}} = h["{{property.var}}"].as( ({{property.type}}) )
          end
        end
      {% end %}
    end

    def initialize(keys : Array, values : Array)
      {% for property in properties %}
        keys.each_index do |i|
          if keys[i] == "{{property.var}}"

            if values[i].as?( ({{property.type}}) )
              self.{{property.var}} = values[i].as( ({{property.type}}) )
            end

          end
        end
      {% end %}
    end

    {{yield}}

    def clone
      {{name.id}}.new({{
                        *properties.map do |property|
                          if property.is_a?(Assign)
                            "@#{property.target.id}.clone".id
                          elsif property.is_a?(TypeDeclaration)
                            "@#{property.var.id}.clone".id
                          else
                            "@#{property.id}.clone".id
                          end
                        end
                      }})
    end

    # Faster way to get CrystalService
    def self.service : CrystalService
      handler = Kemal::Config::HANDLERS.select{|h| h.as?(Kemal::CrystalApi)}.first as Kemal::CrystalApi
      service = handler.crystal_service
      return service
    end

    # TODO check if there is mapping already done by someone else
    def self.create_table_sql(collection)
      columns_chunks = Array(String).new

      {% for property in properties %}
        column_type = "text"
        {% if property.type == Int32 %}
          column_type = "integer"
        {% elsif property.type == Float64 %}
          column_type = "float"
        {% end %}

        column_name = "{{property.var}}"
        unless column_name == "id"
          columns_chunks << "#{column_name} #{column_type}"
        end
      {% end %}

      sql = "create table if not exists #{collection} (
        id serial,
        " +
        columns_chunks.join(", ") + ",
        primary key(id)
      )"

      return sql
    end

  end
end
