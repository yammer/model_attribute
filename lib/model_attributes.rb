require "model_attributes/version"
require "model_attributes/errors"
require "time"
require "oj"

module ModelAttributes
  SUPPORTED_TYPES = [:integer, :boolean, :string, :time]

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

    def set_attributes(attributes, can_set_private_attrs = false)
      attributes.each do |key, value|
        send("#{key}=", value) if respond_to?("#{key}=", can_set_private_attrs)
      end
    end

    def ==(other)
      equal?(other) || (self.class == other.class && compare_attrs(other))
    end
    alias_method :eql?, :==

    def compare_attrs(other)
      if respond_to?(:id)
        id == other.id
      else
        attributes == other.attributes
      end
    end
    private :compare_attrs

    def changes
      @changes ||= {} #HashWithIndifferentAccess.new
    end

    # Serialize attributes as a JSON string.
    #
    #  - Attributes with a nil value are omitted to speed serialization.
    #  - :time attributes are serialized as a Float giving the number of seconds
    #    since the epoch, as this is fastest for serialization and deserialization.
    def attributes_as_json
      attributes_hash = self.class.attributes.each_with_object({}) do |name, attributes|
        value = read_attribute(name)
        unless value.nil?
          value = value.to_f if value.is_a? Time
          attributes[name.to_s] = value
        end
      end
      Oj.dump(attributes_hash, :mode => :strict)
    end

    # Includes the class name and all the attributes and their values.  e.g.
    # "#<User id: 1, paid: true, name: \"Fred\", created_at: 2014-12-25 08:00:00 +0000>"
    def inspect
      attribute_string = self.class.attributes.map do |key|
        "#{key}: #{read_attribute(key).inspect}"
      end.join(', ')
      "#<#{self.class} #{attribute_string}>"
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
      when :time
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
