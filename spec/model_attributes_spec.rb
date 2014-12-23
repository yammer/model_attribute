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

    describe "an integer attribute (id)" do
      it "is nil when unset" do
        expect(user.id).to be_nil
      end

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

      it "stores nil" do
        user.id = 3
        user.id = nil
        expect(user.id).to be_nil
      end
    end

    describe "#changes" do
      let(:changes) { user.changes }

      context "for a model instance created with no attributes" do
        it "is empty" do
          expect(changes).to be_empty
        end
      end

      context "when an attribute is set via a writer method" do
        before(:each) { user.id = 3 }

        it "has an entry from attribute name to [old, new] pair" do
          expect(changes).to include(:id => [nil, 3])
        end

        context "when an attribute is set again" do
          before(:each) { user.id = 5 }

          it "shows the latest value for the attribute" do
            expect(changes).to include(:id => [nil, 5])
          end
        end

        context "when an attribute is set back to its original value" do
          before(:each) { user.id = nil }

          it "does not have an entry for the attribute" do
            expect(changes).to_not include(:id)
          end
        end
      end
    end

    describe "#==" do
      it "returns false if the attributes are different" do
        u1 = User.new.tap { |u| u.id = 1 }
        u2 = User.new.tap { |u| u.id = 2 }
        expect(u1 == u2).to eq(false)
      end

      it "returns false if different attrbutes are set" do
        u1 = User.new.tap { |u| u.id = 1 }
        u2 = User.new
        expect(u1 == u2).to eq(false)
      end

      it "returns true if the attributes are the same" do
        u1 = User.new.tap { |u| u.id = 1 }
        u2 = User.new.tap { |u| u.id = 1 }
        expect(u1 == u2).to eq(true)
      end
    end
  end
end
