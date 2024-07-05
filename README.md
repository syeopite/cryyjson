# cryyjson

Simple crystal bindings to [yyjson](https://github.com/ibireme/yyjson)

Only parsing is supported for now.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     cryyjson:
       github: syeopite/cryyjson
   ```

2. Run `shards install`

## Usage

```crystal
require "cryyjson"

data = File.read("example_data.json").gets_to_end
json = Cryyjson.parse(data)

# API is the exact same as stdlib
typeof(json) # => JSON::Any

json["key"] # => value
```

## Contributing

1. Fork it (<https://github.com/syeopite/cryyjson/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Credits
- [@ibireme](https://github.com/ibireme) - creator of [yyjson](https://github.com/ibireme/yyjson)
