class User
  extend ModelAttribute
  attribute :id,            :integer
  attribute :paid,          :boolean
  attribute :name,          :string
  attribute :created_at,    :time
  attribute :profile,       :json
  attribute :reward_points, :integer, default: 0

  def initialize(attributes = {})
    set_attributes(attributes)
  end
end

class UserWithoutId
  extend ModelAttribute
  attribute :paid,       :boolean
  attribute :name,       :string
  attribute :created_at, :time

  def initialize(attributes = {})
    set_attributes(attributes)
  end
end

RSpec.describe "a class using ModelAttribute" do
  describe "class methods" do
    describe ".attribute" do
      context "passed an unrecognised type" do
        it "raises an error" do
          expect do
            User.attribute :address, :custom_type
          end.to raise_error(ModelAttribute::UnsupportedTypeError,
                             "Unsupported type :custom_type. " +
                             "Must be one of :integer, :boolean, :string, :time, :json.")
        end
      end
    end

    describe ".attributes" do
      it "returns an array of attribute names as symbols" do
        expect(User.attributes).to eq([:id, :paid, :name, :created_at, :profile, :reward_points])
      end
    end

    describe ".attribute_defaults" do
      it "returns a hash of attributes that have non-nil defaults" do
        expect(User.attribute_defaults).to eq({reward_points: 0})
      end
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
        expect { user.id = 3.3 }.to raise_error(RuntimeError)
      end

      it "parses an integer string" do
        user.id = '3'
        expect(user.id).to eq(3)
      end

      it "raises if passed a string it can't parse" do
        expect { user.id = '3a' }.to raise_error(ArgumentError,
                                                 'invalid value for Integer(): "3a"')
      end

      it "stores nil" do
        user.id = 3
        user.id = nil
        expect(user.id).to be_nil
      end

      it "does not provide an id? method" do
        expect(user).to_not respond_to(:id?)
        expect { user.id? }.to raise_error(NoMethodError)
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
        expect { user.paid = '3a' }.to raise_error(RuntimeError,
                                                   'Can\'t cast "3a" to boolean')
      end

      it "stores nil" do
        user.paid = true
        user.paid = nil
        expect(user.paid).to be_nil
      end

      describe "#paid?" do
        it "returns false when unset" do
          expect(user.paid?).to eq(false)
        end

        it "returns false for false attributes" do
          user.paid = false
          expect(user.paid?).to eq(false)
        end

        it "returns true for true attributes" do
          user.paid = true
          expect(user.paid?).to eq(true)
        end
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

      it "does not provide a name? method" do
        expect(user).to_not respond_to(:name?)
        expect { user.name? }.to raise_error(NoMethodError)
      end
    end

    describe "a time attribute (created_at)" do
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

      it "parses integers as milliseconds past the epoch" do
        user.created_at = (now_time.to_f * 1000).to_i
        # Truncating to milliseconds loses precision, so use be_within
        expect(user.created_at).to be_within(0.001).of(now_time)
        expect(user.created_at).to be_a_kind_of(Time)
      end

      it "parses strings to date/times" do
        user.created_at = "2014-12-25 14:00:00 +0100"
        expect(user.created_at).to eq(Time.new(2014, 12, 25, 13, 00, 00))
      end

      it "raises for unparseable strings" do
        expect { user.created_at = "Today, innit?" }.to raise_error(ArgumentError,
                                                        'no time information in "Today, innit?"')
      end

      it "converts Dates to Time" do
        user.created_at = Date.parse("2014-12-25")
        expect(user.created_at).to eq(Time.new(2014, 12, 25, 00, 00, 00))
      end

      it "converts DateTime to Time" do
        user.created_at = DateTime.parse("2014-12-25 13:00:45")
        expect(user.created_at).to eq(Time.new(2014, 12, 25, 13, 00, 45))
      end

      it "stores nil" do
        user.created_at = now_time
        user.created_at = nil
        expect(user.created_at).to be_nil
      end

      it "does not provide a created_at? method" do
        expect(user).to_not respond_to(:created_at?)
        expect { user.created_at? }.to raise_error(NoMethodError)
      end
    end

    describe "a json attribute (profile)" do
      it "is nil when unset" do
        expect(user.profile).to be_nil
      end

      it "stores a string" do
        user.profile = 'Incomplete'
        expect(user.profile).to eq('Incomplete')
      end

      it "stores an integer" do
        user.profile = 3
        expect(user.profile).to eq(3)
      end

      it "stores true" do
        user.profile = true
        expect(user.profile).to eq(true)
      end

      it "stores false" do
        user.profile = false
        expect(user.profile).to eq(false)
      end

      it "stores an array" do
        user.profile = [1, 2, 3]
        expect(user.profile).to eq([1, 2, 3])
      end

      it "stores a hash" do
        user.profile = {'skill' => 8}
        expect(user.profile).to eq({'skill' => 8})
      end

      it "stores nested hashes and arrays" do
        json = {'array' => [1,
                            2,
                            true,
                            {'inner' => true},
                            ['inside', {}]
                           ],
                'hash'  => {'getting' => {'nested' => 'yes'}},
                'boolean' => true
               }
        user.profile = json
        expect(user.profile).to eq(json)
      end

      it "raises when passed an object not supported by JSON" do
        expect { user.profile = Object.new }.to raise_error(RuntimeError,
          "JSON only supports nil, numeric, string, boolean and arrays and hashes of those.")
      end

      it "raises when passed a hash with a non-string key" do
        expect { user.profile = {1 => 'first'} }.to raise_error(RuntimeError,
          "JSON only supports nil, numeric, string, boolean and arrays and hashes of those.")
      end

      it "raises when passed a hash with an unsupported value" do
        expect { user.profile = {'first' => :symbol} }.to raise_error(RuntimeError,
          "JSON only supports nil, numeric, string, boolean and arrays and hashes of those.")
      end

      it "raises when passed an array with an unsupported value" do
        expect { user.profile = [1, 2, nil, :symbol] }.to raise_error(RuntimeError,
          "JSON only supports nil, numeric, string, boolean and arrays and hashes of those.")
      end

      it "stores nil" do
        user.profile = {'foo' => 'bar'}
        user.profile = nil
        expect(user.profile).to be_nil
      end

      it "does not provide a profile? method" do
        expect(user).to_not respond_to(:profile?)
        expect { user.profile? }.to raise_error(NoMethodError)
      end
    end

    describe 'a defaulted attribute (reward_points)' do
      it "returns the default when unset" do
        expect(user.reward_points).to eq(0)
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
        end.to raise_error(ModelAttribute::InvalidAttributeNameError,
                           "Invalid attribute name :spelling_mistake")
      end
    end

    describe "#read_attribute" do
      it "returns the value of an attribute that has been set" do
        user.write_attribute(:id, 3)
        expect(user.read_attribute(:id)).to eq(user.id)
      end

      it "returns nil for an attribute that has not been set" do
        expect(user.read_attribute(:id)).to be_nil
      end

      context "for an attribute with a default" do
        it "returns the default if the attribute has not been set" do
          expect(user.read_attribute(:reward_points)).to eq(0)
        end
      end

      it "raises an error if passed an invalid attribute name" do
        expect do
          user.read_attribute(:spelling_mistake)
        end.to raise_error(ModelAttribute::InvalidAttributeNameError,
                           "Invalid attribute name :spelling_mistake")
      end
    end

    describe "#changes" do
      let(:changes) { user.changes }

      context "for a model instance created with no attributes except defaults" do
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

    describe "#changes_for_json" do
      let(:changes_for_json) { user.changes_for_json }

      context "for a model instance created with no attributes" do
        it "is empty" do
          expect(changes_for_json).to be_empty
        end
      end

      context "when an attribute is set via a writer method" do
        before(:each) { user.id = 3 }

        it "has an entry from attribute name (as a string) to the new value" do
          expect(changes_for_json).to include('id' => 3)
        end

        context "when an attribute is set again" do
          before(:each) { user.id = 5 }

          it "shows the latest value for the attribute" do
            expect(changes_for_json).to include('id' => 5)
          end
        end

        context "when an attribute is set back to its original value" do
          before(:each) { user.id = nil }

          it "does not have an entry for the attribute" do
            expect(changes_for_json).to_not include('id')
          end
        end

        context "if the returned hash is modified" do
          before(:each) { user.changes_for_json.clear }

          it "does not affect subsequent results from changes_for_json" do
            expect(changes_for_json).to include('id' => 3)
          end
        end
      end

      it "serializes time attributes as JSON integer" do
        user.created_at = Time.now
        expect(changes_for_json).to include("created_at" => instance_of(Fixnum))
      end
    end

    describe "#id_changed?" do
      context "with no changes" do
        it "returns false" do
          expect(user.id_changed?).to eq(false)
        end
      end

      context "with changes" do
        before(:each) { user.id = 3 }

        it "returns true" do
          expect(user.id_changed?).to eq(true)
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

    describe "#attributes_for_json" do
      let(:time_now) { Time.now }

      before(:each) do
        user.id = 1
        user.paid = true
        user.created_at = time_now
      end

      it "serializes integer attributes as JSON integer" do
        expect(user.attributes_for_json).to include("id" => 1)
      end

      it "serializes time attributes as JSON integer" do
        expect(user.attributes_for_json).to include("created_at" => instance_of(Fixnum))
      end

      it "serializes string attributes as JSON string" do
        user.name = 'Fred'
        expect(user.attributes_for_json).to include("name" => "Fred")
      end

      it "leaves JSON attributes unchanged" do
        json = {'interests' => ['coding', 'social networks'], 'rank' => 15}
        user.profile = json
        expect(user.attributes_for_json).to include("profile" => json)
      end

      it "omits attributes still set to the default value" do
        expect(user.attributes_for_json).to_not include("name", "reward_points")
      end

      it "includes an attribute changed from its default value" do
        user.name = "Fred"
        expect(user.attributes_for_json).to include("name" => "Fred")
      end

      it "includes an attribute changed from its default value to nil" do
        user.reward_points = nil
        expect(user.attributes_for_json).to include("reward_points" => nil)
      end
    end

    describe "#set_attributes" do
      it "allows mass assignment of attributes" do
        user.set_attributes(id: 5, name: "Sally")
        expect(user.attributes).to include(id: 5, name: "Sally")
      end

      it "ignores keys that have no writer method" do
        user.set_attributes(id: 5, species: "Human")
        expect(user.attributes).to_not include(species: "Human")
      end

      context "for an attribute with a private writer method" do
        before(:all) { User.send(:private, :name=) }
        after(:all)  { User.send(:public,  :name=) }

        it "does not set the attribute" do
          user.set_attributes(id: 5, name: "Sally")
          expect(user.attributes).to_not include(name: "Sally")
        end

        it "sets the attribute if the flag is passed" do
          user.set_attributes({id: 5, name: "Sally"}, true)
          expect(user.attributes).to include(name: "Sally")
        end
      end
    end

    describe "#inspect" do
      let(:user) do
        User.new(id: 1,
                 name: "Fred",
                 created_at: "2014-12-25 08:00",
                 paid: true,
                 profile: {'interests' => ['coding', 'social networks'], 'rank' => 15})
      end

      it "includes integer attributes as 'name: value'" do
        expect(user.inspect).to include("id: 1")
      end

      it "includes boolean attributes as 'name: true/false'" do
        expect(user.inspect).to include("paid: true")
      end

      it "includes string attributes as 'name: \"string\"'" do
        expect(user.inspect).to include('name: "Fred"')
      end

      it "includes time attributes as 'name: <ISO 8601>'" do
        expect(user.inspect).to include("created_at: 2014-12-25 08:00:00 +0000")
      end

      it "includes json attributes as 'name: inspected_json'" do
        expect(user.inspect).to include('profile: {"interests"=>["coding", "social networks"], "rank"=>15}')
      end

      it "includes defaulted attributes" do
        expect(user.inspect).to include('reward_points: 0')
      end

      it "includes the class name" do
        expect(user.inspect).to include("User")
      end

      it "looks like '#<User id: 1, paid: true, name: ..., created_at: ...>'" do
        expect(user.inspect).to eq("#<User id: 1, paid: true, name: \"Fred\", created_at: 2014-12-25 08:00:00 +0000, profile: {\"interests\"=>[\"coding\", \"social networks\"], \"rank\"=>15}, reward_points: 0>")
      end
    end

    describe 'equality with :id field' do
      let(:u1) { User.new(id: 1, name: 'David') }

      context '#==' do
        it 'returns true when ids match, regardless of other attributes' do
          u2 = User.new(id: 1, name: 'Dave')
          expect(u1).to eq(u2)
        end

        it 'returns false when ids do not match' do
          u2 = User.new(id: 2, name: 'David')
          expect(u1).to_not eq(u2)
        end
      end

      context '#eql?' do
        it 'returns true when ids match, regardless of other attributes' do
          u2 = User.new(id: 1, name: 'Dave')
          expect(u1).to eql(u2)
        end

        it 'returns false when ids do not match' do
          u2 = User.new(id: 2, name: 'David')
          expect(u1).to_not eql(u2)
        end
      end
    end

    describe 'equality without :id field' do
      let(:u1) { UserWithoutId.new(name: 'David') }

      context "for models with different attribute values" do
        let(:u2) { UserWithoutId.new(name: 'Dave') }

        it "#== returns false" do
          expect(u1).to_not eq(u2)
        end

        it "#eql? returns false" do
          expect(u1).to_not eql(u2)
        end
      end

      context "for models with different attributes set" do
        let(:u2) { UserWithoutId.new }

        it "#== returns false" do
          expect(u1).to_not eq(u2)
        end

        it "#eql? returns false" do
          expect(u1).to_not eql(u2)
        end
      end

      context "for models with the same attributes set to the same values" do
        let(:u2) { UserWithoutId.new(name: 'David') }

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
