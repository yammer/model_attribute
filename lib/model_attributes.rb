require "model_attributes/version"

module ModelAttributes
  def changes
    @changes ||= HashWithIndifferentAccess.new
  end

  def attribute(name, type)
    (@attribute_names ||= []) << name

    self.class_eval(<<-CODE, __FILE__, __LINE__ + 1)
      def #{name}=(value)
        value = cast(value, #{type.inspect})
        return if value == @#{name}

        if changes.has_key? '#{name}'
          original = changes['#{name}']
        else
          original = @#{name}
        end

        if original == value
          changes.delete('#{name}')
        else
          changes['#{name}'] = [original, value]
        end

        @#{name} = value
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
    def attributes
      self.class.attributes.each_with_object({}) do |name, attributes|
        attributes[name] = send(name)
      end
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
