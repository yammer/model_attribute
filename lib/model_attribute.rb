require "model_attribute/version"
require "model_attribute/casts"
require "model_attribute/errors"
require "time"

module ModelAttribute
  SUPPORTED_TYPES = [:integer, :float, :boolean, :string, :time, :json]

  def self.extended(base)
    base.send(:include, InstanceMethods)
    base.instance_variable_set('@attribute_names',    [])
    base.instance_variable_set('@attribute_types',    {})
    base.instance_variable_set('@attribute_defaults', {})
  end

  def attribute(name, type, opts = {})
    name = name.to_sym
    type = type.to_sym
    raise UnsupportedTypeError.new(type) unless SUPPORTED_TYPES.include?(type)

    @attribute_names          << name
    @attribute_types[name]    = type
    @attribute_defaults[name] = opts[:default] if opts.key?(:default)

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

  def attribute_defaults
    @attribute_defaults
  end

  module InstanceMethods
    def write_attribute(name, value, type = nil)
      name = name.to_sym

      # Don't want to expose attribute types as a method on the class, so access
      # via a back door.
      type ||= self.class.instance_variable_get('@attribute_types')[name]
      raise InvalidAttributeNameError.new(name) unless type

      value = Casts.cast(value, type)
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
      else
        self.class.attribute_defaults[name.to_sym]
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
      return true if equal?(other)
      if respond_to?(:id)
        other.kind_of?(self.class) && id == other.id
      else
        other.kind_of?(self.class) && attributes == other.attributes
      end
    end
    alias_method :eql?, :==

    def changes
      @changes ||= {}
    end

    # Attributes suitable for serializing to a JSON string.
    #
    #  - Attribute keys are strings (for 'strict' JSON dumping).
    #  - Attributes with a default or nil value are omitted to speed serialization.
    #  - :time attributes are serialized as an Integer giving the number of
    #    milliseconds since the epoch.
    def attributes_for_json
      self.class.attributes.each_with_object({}) do |name, attributes|
        value = read_attribute(name)
        if value != self.class.attribute_defaults[name.to_sym]
          value = (value.to_f * 1000).to_i if value.is_a? Time
          attributes[name.to_s] = value
        end
      end
    end

    # Changed attributes suitable for serializing to a JSON string.  Returns a
    # hash from attribute name (as a string) to the new value of that attribute,
    # for attributes that have changed.
    #
    #  - :time attributes are serialized as an Integer giving the number of
    #    milliseconds since the epoch.
    #  - Unlike attributes_for_json, attributes that have changed to a nil value
    #    *are* included.
    def changes_for_json
      hash = {}
      changes.each do |attr_name, (_old_value, new_value)|
        new_value = (new_value.to_f * 1000).to_i if new_value.is_a? Time
        hash[attr_name.to_s] = new_value
      end

      hash
    end

    # Includes the class name and all the attributes and their values.  e.g.
    # "#<User id: 1, paid: true, name: \"Fred\", created_at: 2014-12-25 08:00:00 +0000>"
    def inspect
      attribute_string = self.class.attributes.map do |key|
        "#{key}: #{read_attribute(key).inspect}"
      end.join(', ')
      "#<#{self.class} #{attribute_string}>"
    end
  end
end
