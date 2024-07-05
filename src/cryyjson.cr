require "json"
require "./libyyjson.cr"

# TODO: Write documentation for `Cryyjson`
module Cryyjson
  VERSION = "0.1.0"

  # Parses some JSON string into a JSON::Any object through yyjson
  def self.parse(json) : JSON::Any
    err = LibYYJSON::YYJSONReadError.new()
    document = LibYYJSON.yyjson_read_opts(json, json.bytesize, 0_u32, nil, pointerof(err))
    object = self.parse_object(document.value.root)

    LibYYJSON.yyjson_doc_free(document)

    return JSON::Any.new(object)
  end

  private def self.parse_object(object)
    iterator = LibYYJSON::ObjIter.new()
    LibYYJSON.yyjson_obj_iter_init(object, pointerof(iterator))

    json_object = {} of String => JSON::Any

    while (key = LibYYJSON.yyjson_obj_iter_next(pointerof(iterator)))
      str_key = String.new(key.value.uni.str)
      raw_value = LibYYJSON.yyjson_obj_iter_get_val(key)
      processed_value = self.parse_json_value(raw_value)

      json_object[str_key] = JSON::Any.new(processed_value)
    end

    return json_object
  end

  private def self.parse_array(arr)
    iterator = LibYYJSON::ArrIter.new()
    LibYYJSON.yyjson_arr_iter_init(arr, pointerof(iterator))

    json_array = [] of JSON::Any
    while (value = LibYYJSON.yyjson_arr_iter_next(pointerof(iterator)))
      json_array << JSON::Any.new(self.parse_json_value(value))
    end

    return json_array
  end

  private def self.parse_json_value(value_pointer : Pointer(LibYYJSON::Val)) : JSON::Any::Type
    # Identify value type
    value = value_pointer.value
    value_type = LibYYJSON::YYJSONType.from_value(value.tag & LibYYJSON::JSONValueMask::TYPE_MASK.value)
    value_subtype = LibYYJSON::YYJSONSubType.from_value(value.tag & LibYYJSON::JSONValueMask::SUBTYPE_MASK.value)

    case value_type
    when .null?
      return nil
    when .bool?
      return value_subtype.true? ? true : false
    when .num?
      case value_subtype
      when .uint?
        return Int64.new(value.uni.u64)
      when .sint?
        return Int64.new(value.uni.i64)
      when .real?
        return Float64.new(value.uni.f64)
      end
    when .str?
      return String.new(value.uni.str)
    when .arr?
      return self.parse_array(value_pointer)
    when .obj?
      return self.parse_object(value_pointer)
    else
      raise JSON::Error.new("Invalid type")
    end
  end
end
