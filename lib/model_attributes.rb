require "model_attributes/version"
require "model_attributes/errors"

module ModelAttributes
  SUPPORTED_TYPES = [:integer, :boolean, :string, :datetime]

  def self.extended(base)
    base.send(:include, InstanceMethods)
    base.instance_variable_set('@attribute_names', [])
    base.instance_variable_set('@attribute_types', {})
  end

  def attribute(name, type)
    name = name.to_sym
    type = type.to_sym
    raise UnsupportedTypeError.new(type) unless SUPPORTED_TYPES.include?(type)

    @attribute_names << name
    @attribute_types[name] = type

    self.class_eval(<<-CODE, __FILE__, __LINE__ + 1)
      def #{name}=(value)
        write_attribute(#{name.inspect}, value, #{type.inspect})
      end

      def #{name}
        read_attribute(#{name.inspect})
      end

      def #{name}_changed?
        !!changes[#{name.inspect}]
      end
    CODE

    if type == :boolean
      self.class_eval(<<-CODE, __FILE__, __LINE__ + 1)
        def #{name}?
          !!read_attribute(#{name.inspect})
        end
      CODE
    end
  end

  def attributes
    @attribute_names
  end

  module InstanceMethods
    def write_attribute(name, value, type = nil)
      name = name.to_sym

      # Don't want to expose attribute types as a method on the class, so access
      # via a back door.
      type ||= self.class.instance_variable_get('@attribute_types')[name]
      raise InvalidAttributeNameError.new(name) unless type

      value = cast(value, type)
      return if value == read_attribute(name)

      if changes.has_key? name
        original = changes[name].first
      else
        original = read_attribute(name)
      end

      if original == value
        changes.delete(name)
      else
        changes[name] = [original, value]
      end

      instance_variable_set("@#{name}", value)
    end

    def read_attribute(name)
      ivar_name = "@#{name}"
      if instance_variable_defined?(ivar_name)
        instance_variable_get(ivar_name)
      elsif !self.class.attributes.include?(name.to_sym)
        raise InvalidAttributeNameError.new(name)
      end
    end

    def attributes
      self.class.attributes.each_with_object({}) do |name, attributes|
        attributes[name] = read_attribute(name)
      end
    end

    def ==(other)
      self.class == other.class && attributes == other.attributes
    end
    alias_method :eql?, :==

    def changes
      @changes ||= {} #HashWithIndifferentAccess.new
    end

    def attributes_as_json
      hash_to_serialize = self.class.attributes.each_with_object({}) do |name, hash|
        value = send(name)
        unless value.nil?
          value = value.to_f if value.is_a? Time
          hash[name.to_s] = value
        end
      end

      Oj.dump(hash_to_serialize, mode: :strict)
    end

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
      when :datetime
        case value
        when Time
          value
        when Date, DateTime
          value.to_time
        when Numeric
          Time.at(Float(value))
        else
          Time.parse(value)
        end
      when :string
        String(value)
      else
        raise UnsupportedTypeError.new(type)
      end
    end
  end
end
