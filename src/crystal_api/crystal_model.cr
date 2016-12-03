require "json"

macro crystal_model(name, *properties)
  struct {{name.id}}
    {% for property in properties %}
      getter {{property.var}} : (Nil | {{property.type}})
    {% end %}

    JSON.mapping(
    {% for property in properties %}
      {{property.var}}: (Nil | {{property.type}}),
    {% end %}
    )

    COLUMNS = [
      {% for property in properties %}
        "{{property.var}}",
      {% end %}
    ]



    def initializea({{
                      *properties.map do |field|
                        "@#{field.var} : #{field.type} = #{field.value.is_a?(Nop) ? nil : field.value}"
                      end
                    }})
    end

    def initialize(h : Hash)
      {% for property in properties %}
        if h["{{property.var}}"]?
          if h["{{property.var}}"].as?( (Nil | {{property.type}}) )
            self.{{property.var}} = h["{{property.var}}"].as( (Nil | {{property.type}}) )
          end
        end
      {% end %}
    end

    def initialize(keys : Array, values : Array)
      {% for property in properties %}
        keys.each_index do |i|
          if keys[i] == "{{property.var}}"

            if values[i].as?( (Nil | {{property.type}}) )
              self.{{property.var}} = values[i].as( (Nil | {{property.type}}) )
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

    def to_h
      return {
        {% for property in properties %}
          "{{property.var}}" => {{property.var}},
        {% end %}
      }
    end

    # TODO check if there is mapping already done by someone else
    def self.create_table_sql(collection)
      columns_chunks = Array(String).new

      {% for property in properties %}
        {{ t = "#{property.type}".gsub(/Nil/, "").gsub(/\|/, "").strip }}

        column_type = "text"
        {% if t == "Int32" %}
          column_type = "integer"
        {% elsif t == "Float64" %}
          column_type = "float"
        {% elsif t == "Time" %}
          column_type = "time"
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
