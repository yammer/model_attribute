module Inheritance
  class User
    extend ModelAttribute
    attribute :id,   :integer
    attribute :name, :string

    def initialize(attributes = {})
      set_attributes(attributes)
    end
  end

  class Admin < User
    def self.attributes
      User.attributes
    end

    def self.attribute_defaults
      User.attribute_defaults
    end

    def self.attribute_types
      User.attribute_types
    end
  end

  RSpec.describe "a subclass of a class using ModelAttribute" do
    describe "class methods" do
    end

    describe "instance methods" do
      let(:admin) { Admin.new }

      it "can use attributes" do
        admin.id = 7
        expect(admin.id).to eq(7)
      end
    end
  end
end

