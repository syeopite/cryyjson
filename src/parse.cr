require "string_pool"

struct Cryyjson::Parser
  @string_pool : StringPool?

  def initialize(@json_string : String)
    @bytesize = @json_string.bytesize
  end

  # Parses some JSON string into a JSON::Any object through yyjson
  def parse : JSON::Any
    err = LibYYJSON::YYJSONReadError.new
    document = LibYYJSON.yyjson_read_opts(@json_string, @bytesize, 0_u32, nil, pointerof(err))
    return self.parse_json_value(document.value.root)
  ensure
    document.try { |doc| LibYYJSON.yyjson_doc_free(doc) }
  end

  private def string_pool
    return @string_pool ||= StringPool.new
  end

  private def parse_object(object) : Hash(String, JSON::Any)
    iterator = LibYYJSON.yyjson_obj_iter_with(object)

    json_object = {} of String => JSON::Any

    while (key = LibYYJSON.yyjson_obj_iter_next(pointerof(iterator)))
      str_key = string_pool.get(key.value.uni.str, get_length_of_json_value(key.value))

      raw_value = LibYYJSON.yyjson_obj_iter_get_val(key)
      processed_value = self.parse_json_value(raw_value)

      json_object[str_key] = processed_value
    end

    return json_object
  end

  private def parse_array(arr) : Array(JSON::Any)
    iterator = LibYYJSON.yyjson_arr_iter_with(arr)

    return Array.new(iterator.max) do
      self.parse_json_value(LibYYJSON.yyjson_arr_iter_next(pointerof(iterator)))
    end
  end

  private def parse_json_value(value_pointer : Pointer(LibYYJSON::Val)) : JSON::Any
    # Identify value type
    value = value_pointer.value

    value_type = LibYYJSON::YYJSONType.from_value(value.tag & LibYYJSON::JSONValueMask::TYPE_MASK.value)
    value_subtype = LibYYJSON::YYJSONSubType.from_value(value.tag & LibYYJSON::JSONValueMask::SUBTYPE_MASK.value)

    parsed = case value_type
             when .obj?  then self.parse_object(value_pointer)
             when .str?  then string_pool.get(value.uni.str, get_length_of_json_value(value))
             when .arr?  then self.parse_array(value_pointer)
             when .null? then nil
             when .bool? then value_subtype.true? ? true : false
             when .num?
               case value_subtype
               when .uint? then value.uni.u64
               when .sint? then value.uni.i64
               when .real? then value.uni.f64
               else
                 raise JSON::Error.new("Invalid number subtype")
               end
             else
               raise JSON::Error.new("Invalid type")
             end

    return JSON::Any.new(parsed)
  end

  private def parse_json_value(value_pointer : Pointer(LibYYJSON::Val)) : JSON::Any
    # Identify value type
    value = value_pointer.value

    value_type = LibYYJSON::YYJSONType.from_value(value.tag & LibYYJSON::JSONValueMask::TYPE_MASK.value)
    value_subtype = LibYYJSON::YYJSONSubType.from_value(value.tag & LibYYJSON::JSONValueMask::SUBTYPE_MASK.value)

    parsed = case value_type
             when .obj?  then self.parse_object(value_pointer)
             when .str?  then string_pool.get(value.uni.str, get_length_of_json_value(value))
             when .arr?  then self.parse_array(value_pointer)
             when .null? then nil
             when .bool? then value_subtype.true? ? true : false
             when .num?
               case value_subtype
               when .uint? then Int64.new(value.uni.u64)
               when .sint? then Int64.new(value.uni.i64)
               when .real? then Float64.new(value.uni.f64)
               else
                 raise JSON::Error.new("Invalid number subtype")
               end
             else
               raise JSON::Error.new("Invalid type")
             end

    return JSON::Any.new(parsed)
  end

  private macro get_length_of_json_value(value)
    {{value}}.tag >> LibYYJSON::JSONValueMask::TAG_BIT.value
  end
end
