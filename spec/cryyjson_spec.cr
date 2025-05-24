require "./spec_helper"

# Taken from Crystal Stdlib
private def it_parses(string, expected_value, file = __FILE__, line = __LINE__)
  it "parses #{string}", file, line do
    Cryyjson.parse(string).raw.should eq(expected_value)
  end
end

describe Cryyjson do
  it_parses %("1"), "1"
  it_parses "1", 1
  it_parses "{}", {} of String => JSON::Any
  it_parses %({"foo": 1}), {"foo" => 1}
  it_parses %({"foo": 1, "bar": 1.5}), {"foo" => 1, "bar" => 1.5}
  it_parses %({"fo\\no": 1}), {"fo\no" => 1}

  it "parses nested json" do
    experimental = {
      "key" => "value",
      "obj" => {
        "arr" => [
          {"a" => "b"},
          {"b" => "c"},
        ],
        "str" => "str",
        "num" => 1234,
      },
      "key2" => "key2",
    }

    Cryyjson.parse(experimental.to_json).raw.should eq(experimental)
  end

  it_parses "[1,2,3,4,5]", [1, 2, 3, 4, 5]
end
