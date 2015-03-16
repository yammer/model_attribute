# Change Log

All notable changes to this project will be documented in this file.

## HEAD

- **New method**: #changes_for_json  Returns a hash from attribute name to its
  new value, suitable for serialization to a JSON string.  Easily generate the
  payload to send in an HTTP PUT to a web service.

- ***New attribute type: json***

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
