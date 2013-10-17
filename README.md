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

    (d)->
      [t] = d._id.split("/")
      if t is 'user' emit(d._id, 1)

    User < Dolly::Base
      database_name 'db'
      set_design_doc 'dolly' #defaults to 'dolly'

      property :name, :surname, :address
    end

    User.all #Dolly::Collection #<#User...>, <#User...>

    user = User.find "a1b2d3e" #<#User...>
    user.name

    #Return a User object based on the custom view.
    User.view 'view_name', {key: ["a", "b", "c"], reduce: true} #Returns a simple HTTParty request

    #Save doc
    user.email = 'foo'
    user.save #user.save! exists but doesn do anything yet.


## TODO
  Add to do's

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
