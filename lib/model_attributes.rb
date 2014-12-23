require "model_attributes/version"

module ModelAttributes
  def self.extended(base)
    base.send(:include, InstanceMethods)
  end

  def attribute(name, type)
    name = name.to_sym
    (@attribute_names ||= []) << name

    self.class_eval(<<-CODE, __FILE__, __LINE__ + 1)
      def #{name}=(value)
        write_attribute(#{name.inspect}, value, #{type.inspect})
      end

      def #{name}
        @#{name}
      end
    CODE
  end

  def attributes
    @attribute_names
  end

  module InstanceMethods
    def write_attribute(name, value, type = nil)
      name = name.to_s
      value = cast(value, type) if type
      return if value == read_attribute(name)

      if changes.has_key? name
        original = changes[name]
      else
        original = read_attribute(name)
      end

      if original == value
        changes.delete(name)
      else
        changes[name] = [original, value]
      end

      original = instance_variable_set("@#{name}", value)
    end

    def read_attribute(name)
      ivar_name = "@#{name}"
      instance_variable_get(ivar_name) if instance_variable_defined?(ivar_name)
    end

    def attributes
      self.class.attributes.each_with_object({}) do |name, attributes|
        attributes[name] = send(name)
      end
    end

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
        Time.at(Float(value)) rescue Time.parse(value)
      when :string
        String(value)
      else
        raise "Unsupported type #{type.inspect}"
      end
    end
  end
end
