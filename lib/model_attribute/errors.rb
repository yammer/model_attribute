module ModelAttribute
  class InvalidAttributeNameError < StandardError
    def initialize(attribute_name)
      super "Invalid attribute name #{attribute_name.inspect}"
    end
  end

  class UnsupportedTypeError < StandardError
    def initialize(type)
      types_list = Casts::SUPPORTED_TYPES.map(&:inspect).join(', ')
      super "Unsupported type #{type.inspect}. Must be one of #{types_list}."
    end
  end

  class RequiredFieldError < StandardError
    def initialize(name)
      super "Field #{name} is required"
    end


  end
end
