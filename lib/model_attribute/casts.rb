module ModelAttribute
  module Casts
    class << self
      def cast(value, type)
        return nil if value.nil?

        case type
        when :integer
          int = Integer(value)
          float = Float(value)
          raise "Can't cast #{value.inspect} to an integer without loss of precision" unless int == float
          int
        when :boolean
          if !!value == value
            value
          elsif value == 't'
            true
          elsif value == 'f'
            false
          else
            raise "Can't cast #{value.inspect} to boolean"
          end
        when :time
          case value
          when Time
            value
          when Date, DateTime
            value.to_time
          when Integer
            # Assume milliseconds since epoch.
            Time.at(value / 1000.0)
          when Numeric
            # Numeric, but not an integer. Assume seconds since epoch.
            Time.at(value)
          else
            Time.parse(value)
          end
        when :string
          String(value)
        when :json
          if valid_json?(value)
            value
          else
            raise "JSON only supports nil, numeric, string, boolean and arrays and hashes of those."
          end
        else
          raise UnsupportedTypeError.new(type)
        end
      end

      private

      def valid_json?(value)
        (value == nil         ||
         value == true        ||
         value == false       ||
         value.is_a?(Numeric) ||
         value.is_a?(String)  ||
         (value.is_a?(Array) && valid_json_array?(value)) ||
         (value.is_a?(Hash)  && valid_json_hash?(value) ))
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
