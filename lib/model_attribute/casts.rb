module ModelAttribute
  module Casts
    SUPPORTED_TYPES = %i[integer float boolean string time json]

    # TODO: Refactor and improve by adding types as middleware
    class << self
      def cast(value, type)
        return if value.nil?
        return send("valid_#{type}", value) if SUPPORTED_TYPES.include? type
        return raise UnsupportedTypeError.new(type) unless Object.const_defined?(type) ||
          value.is_a?(type)
        value
      end

      private

      def valid_integer(value)
        int = Integer(value)
        float = Float(value)
        raise ArgumentError, "Can't cast #{value.inspect} to an integer without loss of precision" unless int == float
        int
      end

      def valid_float(value)
        Float(value)
      end

      def valid_boolean(value)
        return value if !!value == value
        return true  if %w[t true].include?(value)
        return false if %w[f false].include?(value)
        raise ArgumentError, "Can't cast #{value.inspect} to boolean"
      end

      def valid_time(value)
        {
          "Time"     => -> (val) { val },
          "Date"     => -> (val) { val.to_time },
          "DateTime" => -> (val) { val.to_time },
          "Integer"  => -> (val) { Time.at(val / 1000.0) },
          "Numeric"  => -> (val) { Time.at(val) },
          "Float"    => -> (val) { Time.at(val) }
        }[value.class.to_s].call(value)
      rescue NoMethodError
        Time.parse(value)
      end

      def valid_string(value)
        String(value)
      end

      def valid_json(value)
        if valid_json?(value)
          value
        else
          raise ArgumentError, "JSON only supports nil, numeric, string, boolean and arrays and hashes of those."
        end
      end

      def valid_json?(value)
        (value == nil         ||
         value == true        ||
         value == false       ||
         value.is_a?(Numeric) ||
         value.is_a?(String)  ||
         (value.is_a?(Array) && valid_json_array?(value)) ||
         (value.is_a?(Hash)  && valid_json_hash?(value)))
      end

      def valid_json_array?(array)
        array.all? { |value| valid_json?(value) }
      end

      def valid_json_hash?(hash)
        hash.all? do |key, value|
          key.is_a?(String) && valid_json?(value)
        end
      end
    end
  end
end
