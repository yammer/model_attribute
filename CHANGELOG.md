# Change Log

All notable changes to this project will be documented in this file.

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
