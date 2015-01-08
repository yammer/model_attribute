module ModelAttributes
  class InvalidAttributeNameError < StandardError
    def initialize(attribute_name)
      super "Invalid attribute name #{attribute_name.inspect}"
    end
  end

  class UnsupportedTypeError < StandardError
    def initialize(type)
      super("Unsupported type #{type.inspect}. " +
            "Must be one of :integer, :boolean, :datetime, :string.")
    end
  end
end
