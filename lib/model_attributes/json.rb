module ModelAttributes
  module Json
    class << self
      def valid?(value)
        (value == nil         ||
         value == true        ||
         value == false       ||
         value.is_a?(Numeric) ||
         value.is_a?(String)  ||
         (value.is_a?(Array) && valid_array?(value)) ||
         (value.is_a?(Hash)  && valid_hash?(value) ))
      end

      private

      def valid_array?(array)
        array.all? { |value| valid?(value) }
      end

      def valid_hash?(hash)
        hash.all? do |key, value|
          key.is_a?(String) && valid?(value)
        end
      end
    end
  end
end
