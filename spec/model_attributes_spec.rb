class User
  extend ModelAttributes
  attribute :id,         :integer
  attribute :paid,       :boolean
  attribute :name,       :string
  attribute :created_at, :datetime
end

RSpec.describe "a class using attributes" do
  describe ".attributes" do
    it "returns an array of attribute names as symbols"
  end

  describe "an instance of the class" do
    let(:user) { User.new }
    it "responds to #write_attribute"
    it "responds to #changes"
    describe "an integer attribute" do
      describe "#id=" do
        it "stores an integer"
        it "raises when passed a float"
        it "parses and integer string"
        it "raises if passed a string it can't parse"
        it "stores nil"
      end
    end
  end
end
