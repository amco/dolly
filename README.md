# Dolly3

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/dolly3`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dolly3'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dolly3

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/dolly3.


## Migrating from couch 1.x to 2.x

[Official docs](https://docs.couchdb.org/en/2.3.1/install/index.html)


You will need to uninstall the couchdb service with brew

`brew services stop couchdb`
`brew services uninstall couchdb`

Download the application from the following source

http://couchdb.apache.org/#download

launch fauxton and check your installation

Copy [this file](https://github.com/apache/couchdb/blob/master/rel/overlay/bin/couchup) into your filesystem


make it executable

`chmod +x couchup.py`

and run it

`./couchup.py -h`

You might need to install python 3 and pip3 and the following libs

`pip3 install requests progressbar2`

move your .couch files into the specified `database_dir` in your [fauxton config](http://127.0.0.1:5984/_utils/#_config/couchdb@localhost)


```
$ ./couchup list           # Shows your unmigrated 1.x databases
$ ./couchup replicate -a   # Replicates your 1.x DBs to 2.x
$ ./couchup rebuild -a     # Optional; starts rebuilding your views
$ ./couchup delete -a      # Deletes your 1.x DBs (careful!)
$ ./couchup list           # Should show no remaining databases!
```
