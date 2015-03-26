# ModelAttribute

Simple attributes for a non-ActiveRecord model.

 - Stores attributes in instance variables.
 - Type casting and checking.
 - Dirty tracking.
 - List attribute names and values.
 - Handles integers, booleans, strings and times - a set of types that are very
   easy to persist to and parse from JSON.
 - Supports efficient serialization of attributes to JSON.
 - Mass assignment - handy for initializers.

Why not [Virtus][virtus-gem]?  Virtus doesn't provide attribute tracking, and
doesn't integrate with [ActiveModel::Dirty][am-dirty].  So if you're not using
ActiveRecord, but you need attributes with dirty tracking, ModelAttribute may be
what you're after.  For example, it works very well for a model that fronts an
HTTP web service, and you want dirty tracking so you can PATCH appropriately.

Also in favor of ModelAttribute:

 - It's simple - less than [200 lines of code][source].
 - It supports efficient serialization and deserialization to/from JSON.

[virtus-gem]:https://github.com/solnic/virtus
[am-dirty]:https://github.com/rails/rails/blob/v3.0.20/activemodel/lib/active_model/dirty.rb
[source]:https://github.com/yammer/model_attribute/blob/master/lib/model_attribute.rb

## Usage

```ruby
require 'model_attribute'
class User
  extend ModelAttribute
  attribute :id,         :integer
  attribute :paid,       :boolean
  attribute :name,       :string
  attribute :created_at, :time
  attribute :grades,     :json

  def initialize(attributes = {})
    set_attributes(attributes)
  end
end

User.attributes # => [:id, :paid, :name, :created_at, :grades]
user = User.new

user.attributes # => {:id=>nil, :paid=>nil, :name=>nil, :created_at=>nil, :grades=>nil}

# An integer attribute
user.id # => nil

user.id = 3
user.id # => 3

# Stores values that convert cleanly to an integer
user.id = '5'
user.id # => 5

# Protects you against nonsense assignment
user.id = '5error'
ArgumentError: invalid value for Integer(): "5error"

# A boolean attribute
user.paid # => nil
user.paid = true

# Booleans also define a predicate method (ending in '?')
user.paid?  # => true

# Conversion from strings used by databases.
user.paid = 'f'
user.paid # => false
user.paid = 't'
user.paid # => true

# A :time attribute
user.created_at = Time.now
user.created_at # => 2015-01-08 15:57:05 +0000

# Also converts from other reasonable time formats
user.created_at = "2014-12-25 14:00:00 +0100"
user.created_at # => 2014-12-25 13:00:00 +0000
user.created_at = Date.parse('2014-01-08')
user.created_at # => 2014-01-08 00:00:00 +0000
user.created_at = DateTime.parse("2014-12-25 13:00:45")
user.created_at # => 2014-12-25 13:00:45 +0000
# Convert from seconds since the epoch
user.created_at = Time.now.to_f
user.created_at # => 2015-01-08 16:23:02 +0000
# Or milliseconds since the epoch
user.created_at = 1420734182000
user.created_at # => 2015-01-08 16:23:02 +0000

# A :json attribute is schemaless and accepts the basic JSON types - hash,
# array, nil, numeric, string and boolean.
user.grades = {'maths' => 'A', 'history' => 'C'}
user.grades # => {"maths"=>"A", "history"=>"C"}
user.grades = ['A', 'A*', 'C']
user.grades # => ["A", "A*", "C"]
user.grades = 'AAB'
user.grades # => "AAB"
user.grades = Time.now
# => RuntimeError: JSON only supports nil, numeric, string, boolean and arrays and hashes of those.

# read_attribute and write_attribute methods
user.read_attribute(:created_at)
user.write_attribute(:name, 'Fred')

# View attributes
user.attributes # => {:id=>5, :paid=>true, :name=>"Fred", :created_at=>2015-01-08 15:57:05 +0000, :grades=>{"maths"=>"A", "history"=>"C"}}
user.inspect # => "#<User id: 5, paid: true, name: \"Fred\", created_at: 2015-01-08 15:57:05 +0000, grades: {\"maths\"=>\"A\", \"history\"=>\"C\"}>"

# Mass assignment
user.set_attributes(name: "Sally", paid: false)
user.attributes # => {:id=>5, :paid=>false, :name=>"Sally", :created_at=>2015-01-08 15:57:05 +0000}

# Efficient JSON serialization and deserialization.
# Attributes with nil values are omitted.
user.attributes_for_json
# => {"id"=>5, "paid"=>true, "name"=>"Fred", "created_at"=>1421171317762}
require 'oj'
Oj.dump(user.attributes_for_json, mode: :strict)
# => "{\"id\":5,\"paid\":true,\"name\":\"Fred\",\"created_at\":1421171317762}"
user2 = User.new(Oj.load(json, strict: true))

# Change tracking.  A much smaller set of function than that provided by
# ActiveModel::Dity.
user.changes # => {:id=>[nil, 5], :paid=>[nil, true], :created_at=>[nil, 2015-01-08 15:57:05 +0000], :name=>[nil, "Fred"]}
user.name_changed?  # => true
# If you need the new values to send as a PUT to a web service
user.changes_for_json # => {"id"=>5, "paid"=>true, "name"=>"Fred", "created_at"=>1421171317762}
# If you're imitating ActiveRecord behaviour, changes are cleared after
# after_save callbacks, but before after_commit callbacks.
user.changes.clear
user.changes # => {}

# Equality of all the attribute values match
another = User.new
another.id = 5
another.paid = true
another.created_at = user.created_at
another.name = 'Fred'

user == another   # => true
user === another  # => true
user.eql? another # => true

# Making some attributes private

class User
  extend ModelAttribute
  attribute :events, :string
  private :events=

  def initialize(attributes)
    # Pass flag to set_attributes to allow setting attributes with private writers
    set_attributes(attributes, true)
  end

  def add_event(new_event)
    events ||= ""
    events += new_event
  end
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'model_attribute'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install model_attribute

## Contributing

1. Fork it ( https://github.com/[my-github-username]/model_attribute/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
