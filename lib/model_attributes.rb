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
    def write_attribute(name, value, type)
      name = name.to_s
      #value = cast(value, type)
      return if value == instance_variable_get("@#{name}")

      if changes.has_key? name
        original = changes[name]
      else
        original = instance_variable_get("@#{name}")
      end

      if original == value
        changes.delete(name)
      else
        changes[name] = [original, value]
      end

      original = instance_variable_set("@#{name}", value)
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
  end
end
