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

Add config/couchdb.yml

sample file:

```yml
defaults: &defaults
  host: localhost
  port: 5984
  protocol: http
  design: 'test'

development:
  <<: *defaults
  name: dolly

test:
  <<: *defaults
  name: dolly_test

production:
  <<: *defaults
  name: dolly_production
```

The model requires a view on your couch server:

```coffeescript
(d)->
  if d._id
    [str, t, id] = d._id.match /([^/]+)[/](.+)
    emit [t, id], 1 if t and id
```

This view, and the database on config/couchdb.yml will be added with the task:

```rake db:setup```

####Document Model

```ruby
class User < Dolly::Base
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
  * Generators for creating views for attributes search on models.
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
