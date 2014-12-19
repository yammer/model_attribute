class User
  extend ModelAttributes
  attribute :id,         :integer
  attribute :paid,       :boolean
  attribute :name,       :string
  attribute :created_at, :datetime
end

RSpec.describe "a class using ModelAttributes" do
  describe ".attributes" do
    it "returns an array of attribute names as symbols" do
      expect(User.attributes).to eq([:id, :paid, :name, :created_at])
    end
  end

  describe "an instance of the class" do
    let(:user) { User.new }
    it "responds to #write_attribute"
    it "responds to #changes"
    describe "an integer attribute" do
      describe "#id=" do
        it "stores an integer" do
          user.id = 3
          expect(user.id).to eq(3)
        end

        it "stores an integer passed as a float" do
          user.id = 3.0
          expect(user.id).to eq(3)
        end

        it "raises when passed a float with non-zero decimal part" do
          expect { user.id = 3.3 }.to raise_error
        end

        it "parses an integer string" do
          user.id = '3'
          expect(user.id).to eq(3)
        end

        it "raises if passed a string it can't parse" do
          expect { user.id = '3a' }.to raise_error
        end

        it "stores nil"
      end
    end
  end
end
