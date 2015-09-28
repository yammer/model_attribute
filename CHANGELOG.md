# Change Log

All notable changes to this project will be documented in this file.

## 3.0.0

- **Breaking change**: All casting errors raise `ArgumentError`. Previously some
  errors during casting would raise `RuntimeError`.
  Thanks to [@gotascii](https://github.com/gotascii) for the report.

## 2.1.0

- **New feature**: default values.  Allows you to specify a default value like
  so:
```
class User
  attribute :name, :string, default: 'Michelle'
end

User.new.name
# => 'Michelle'
```

## 2.0.0

- **Breaking change**: Rename to `ModelAttribute` (no trailing 's') to avoid name
  clash with another gem.

## 1.4.0

- **New method**: #changes_for_json  Returns a hash from attribute name to its
  new value, suitable for serialization to a JSON string.  Easily generate the
  payload to send in an HTTP PUT to a web service.

- **New attribute type: json**  Store an array/hash/etc. built using the basic
  JSON data types: nil, numeric, string, boolean, hash and array.

## 1.3.0

- **Breaking change**: Parsing an integer to a time attribute, the integer is
  treated as the number of milliseconds since the epoch (not the number of
  seconds).  `attributes_as_json` emits integers for time attributes.

## 1.2.0

- **Breaking change**: `attributes_as_json` removed; replaced with
  `attributes_for_json`.  You will have to serialize this yourself:
  `Oj.dump(attributes_for_json, mode: :strict)`.  This allows you to modify the
  returned hash before serializing it.

## 1.1.0

- Initial release
