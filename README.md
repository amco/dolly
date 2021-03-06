# Dolly

Dolly is a Object Oriented CouchDB interface to interact with the JSON documents through CouchDB's RESTful API.

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

The database on config/couchdb.yml will be added with the task:

```rake db:setup```

Since 0.6 Dolly will not require couch-view for find, all, first and last methods.

You can save your custom views as coffescript files inside ```db/designs/*.map.coffee```
And push them into the default design document with:

```rake db:design```

This will not replace de default find view.

####Initializer

```ruby
#config/initializers/dolly.rb
Dolly.config do |config|
  config.log_requests = true
  config.log = :rails
  config.log_path = 'path/to/log'
end
```

####Document Model

```ruby
class User < Dolly::Document
  database_name 'db'

  property :name, :surname, :address
  property :date_of_birth, class_name: Date, default: Date.today
end

User.all #Dolly::Collection #<#User...>, <#User...>

user = User.find "a1b2d3e" #<#User...>
user.name

#Return a User object based on the custom view. `include_docs` is always true for this method.
response = User.view '_design/<design_document_name>/_view/<view_name>', {key: <key>, reduce: true}
user = User.new.from_json response


# Save doc
user.email = 'foo'
user.save #user.save! exists but doesn do anything yet.

#New Doc
user = User.new
user.name = 'A'
user.save

user = User.new name: 'A'
user.save

user = User.create name: 'A'

#Quering available

User.all
User.first
User.last

# Bulk save

#Bulk saving works adding docs to the bulk_document property.

Dolly::Document.bulk_document << User.new name: 'foo'

# bulk_document includes :[], :<<, :first, :last, :to_a, :count
# it is forwarding to Set, so this will avoid duplicated documents.
# You can add as many documents as you want.
# To trigger the remote save you have to call.

Dolly::Document.bulk_save

```

## TODO
  * Generators for creating views for attributes search on models.
  * Validations?
  * Dirty Tracking?

  Add to do's

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
