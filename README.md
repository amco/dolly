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

<tt>
  User < Dolly::Base
    database_name 'db'
    set_design_doc 'dolly' #defaults to 'dolly'

    property :name, :surname, :address
  end

  User.all #Dolly::Collection #<#User...>, <#User...>

  user = User.find "a1b2d3e" #<#User...>
  user.name

  #TODO: should return a User object based on the custom view.
  User.view 'view_name', {key: ["a", "b", "c"], reduce: true} #Returns a simple HTTParty request
</tt>



## TODO
  This is a simple find and all interface for getting documents
  Still need to be able to update, create and delete those documents

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
