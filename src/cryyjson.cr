require "json"
require "./libyyjson.cr"
require "./parse.cr"

# TODO: Write documentation for `Cryyjson`
module Cryyjson
  VERSION = "0.1.0"

  # Parses some JSON string into a JSON::Any object through yyjson
  def self.parse(json) : JSON::Any
    Cryyjson::Parser.new(json).parse
  end
end
