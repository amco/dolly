# Dolly

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'dolly'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dolly

## Usage

The model requires a view on your couch server:

```coffeescript
(d)->
  [t] = d._id.split("/")
  if t is 'user' emit(d._id, 1)
```

```ruby
User < Dolly::Base
  database_name 'db'
  set_design_doc 'dolly' #defaults to 'dolly'

  property :name, :surname, :address
  property :date_of_birth, class_name: Date, default: Date.today
end

User.all #Dolly::Collection #<#User...>, <#User...>

user = User.find "a1b2d3e" #<#User...>
user.name

#Return a User object based on the custom view.
user = User.view 'view_name', {key: ["a", "b", "c"], reduce: true}


# Save doc
user.email = 'foo'
user.save #user.save! exists but doesn do anything yet.

#New Doc
user = User.new
user.name = 'A'
user.save
```

## TODO
  * Generators for creating a Model with its couch views
  * Validations?
  * Dirty Tracking?
  * Create method
  * intializer with properties ```User.new name: 'Foo'```
 
  Add to do's

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
