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

    describe "a boolean attribute (paid)" do
      it "is nil when unset" do
        expect(user.paid).to be_nil
      end

      it "stores true" do
        user.paid = true
        expect(user.paid).to eq(true)
      end

      it "stores false" do
        user.paid = false
        expect(user.paid).to eq(false)
      end

      it "parses 't' as true" do
        user.paid = 't'
        expect(user.paid).to eq(true)
      end

      it "parses 'f' as false" do
        user.paid = 'f'
        expect(user.paid).to eq(false)
      end

      it "raises if passed a string it can't parse" do
        expect { user.paid = '3a' }.to raise_error
      end

      it "stores nil" do
        user.paid = true
        user.paid = nil
        expect(user.paid).to be_nil
      end
    end

    describe "a string attribute (name)" do
      it "is nil when unset" do
        expect(user.name).to be_nil
      end

      it "stores a string" do
        user.name = 'Fred'
        expect(user.name).to eq('Fred')
      end

      it "casts an integer to a string" do
        user.name = 3
        expect(user.name).to eq('3')
      end

      it "stores nil" do
        user.name = 'Fred'
        user.name = nil
        expect(user.name).to be_nil
      end
    end

    describe "a datetime attribute (created_at)" do
      let(:now_time) { Time.now }

      it "is nil when unset" do
        expect(user.created_at).to be_nil
      end

      it "stores a Time object" do
        user.created_at = now_time
        expect(user.created_at).to eq(now_time)
      end

      it "parses floats as seconds past the epoch" do
        user.created_at = now_time.to_f
        # Going via float loses precision, so use be_within
        expect(user.created_at).to be_within(0.0001).of(now_time)
        expect(user.created_at).to be_a_kind_of(Time)
      end

      it "parses strings to date/times" do
        user.created_at = "2014-12-25 14:00:00 +0100"
        expect(user.created_at).to eq(Time.new(2014, 12, 25, 13, 00, 00))
      end

      it "raises for unparseable strings" do
        expect { user.created_at = "Today, innit?" }.to raise_error
      end

      it "converts Dates to Time" do
        user.created_at = Date.parse("2014-12-25")
        expect(user.created_at).to eq(Time.new(2014, 12, 25, 00, 00, 00))
      end

      it "converts DateTime to Time" do
        user.created_at = Date.parse("2014-12-25")
        expect(user.created_at).to eq(Time.new(2014, 12, 25, 00, 00, 00))
      end

      it "stores nil" do
        user.created_at = now_time
        user.created_at = nil
        expect(user.created_at).to be_nil
      end
    end

    describe "#write_attribute" do
      it "does the same casting as using the writer method" do
        user.write_attribute(:id, '3')
        expect(user.id).to eq(3)
      end

      it "raises an error if passed an invalid attribute name" do
        expect do
          user.write_attribute(:spelling_mistake, '3')
        end.to raise_error(ModelAttributes::InvalidAttributeNameError,
                           "Invalid attribute name :spelling_mistake")
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

    describe "#attributes" do
      let(:time_now) { Time.now }

      before(:each) do
        user.id = 1
        user.paid = true
        user.created_at = time_now
      end

      it "returns a hash including each set attribute" do
        expect(user.attributes).to include(id: 1, paid: true, created_at: time_now)
      end

      it "returns a hash with a nil value for each unset attribute" do
        expect(user.attributes).to include(name: nil)
      end
    end

    describe "equality" do
      let(:u1) { User.new.tap { |u| u.id = 1 } }

      context "for models with different attribute values" do
        let(:u2) { User.new.tap { |u| u.id = 2 } }

        it "#== returns false" do
          expect(u1).to_not eq(u2)
        end

        it "#eql? returns false" do
          expect(u1).to_not eql(u2)
        end
      end

      context "for models with different attributes set" do
        let(:u2) { User.new }

        it "#== returns false" do
          expect(u1).to_not eq(u2)
        end

        it "#eql? returns false" do
          expect(u1).to_not eql(u2)
        end
      end

      context "for models with the same attributes set to the same values" do
        let(:u2) { User.new.tap { |u| u.id = 1 } }

        it "#== returns true" do
          expect(u1).to eq(u2)
        end

        it "#eql? returns true" do
          expect(u1).to eql(u2)
        end
      end
    end
  end
end
