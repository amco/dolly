# Dolly

CouchDB adapter for Ruby. The thing you move your couch with...

![example workflow](https://github.com/amco/dolly/actions/workflows/ruby.yml/badge.svg)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dolly'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dolly

Configure CouchDB in `config/couchdb.yml` (see the [sample config](config/couchdb.yml) in this repo).

## Usage

Define documents as usual:

```ruby
class FooBar < Dolly::Document
  property :foo, :bar
  timestamps!
end

doc = FooBar.create(foo: 'a', bar: 'b')
FooBar.find(doc.id)
```

The public `Dolly::Connection` API (`get`, `post`, `put`, `delete`, `request`, `view`, `attach`, `uuids`, etc.) is unchanged for application code.

### Connection reuse (Curb)

Dolly uses [Curb](https://github.com/taf2/curb) under the hood. Newer Curb releases keep HTTP connections alive, which previously leaked one TCP socket per Dolly request and could exhaust CouchDB's accept backlog during bursts (Sidekiq jobs, seeds, Passenger workers).

Dolly now reuses **one `Curl::Easy` handle per thread** via internal `Dolly::Curl`
collaborators (`Connection` for transport/retries, `WriteReconciler` for ambiguous writes):

- Persistent keep-alive to CouchDB without opening a new socket on every call
- Safe for typical **Passenger** (one request per thread/process) and **Sidekiq** (one job per thread) deployments
- Not safe under fiber-based servers that interleave multiple Dolly requests on a single thread

### Stale keep-alive handling

If CouchDB closes an idle keep-alive socket, Curb may raise a transport error (`GotNothingError`, `RecvError`, `SendError`, `PartialFileError`). Dolly always discards the dead handle, then:

| Request | Behavior |
|---------|----------|
| `GET`, `HEAD` | Retry once on a fresh connection |
| Read-only `POST` (`/_find`, `/_all_docs`) | Retry once on a fresh connection |
| Document `PUT` | Reconcile by reading the document; succeed if content matches, retry once if the write clearly did not land, otherwise raise |
| Document `DELETE` (with `rev`) | Reconcile by reading the document; succeed if gone/deleted, retry once if the same rev is still present, otherwise raise |
| `POST /_bulk_docs` | Reconcile via `/_all_docs`; retry only documents that clearly did not apply |
| Attachments and other writes | Do **not** blind-retry; raise |

### `Dolly::AmbiguousWriteError`

Raised when a write may or may not have been applied (transport failed after the request was possibly processed, and reconciliation cannot prove the outcome).

```ruby
begin
  doc.save!
rescue Dolly::AmbiguousWriteError => e
  e.method # => :put
  e.uri    # => #<URI::HTTP ...>
  e.cause  # => original Curl::Err::*
end
```

Handle this in jobs/seeds by reloading or re-checking the document before retrying the business operation.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

```bash
bundle exec rake test
```

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/amco/dolly.

## Migrating from CouchDB 1.x to 2.x

[Official docs](https://docs.couchdb.org/en/2.3.1/install/index.html)

You will need to uninstall the couchdb service with brew:

```bash
brew services stop couchdb
brew services uninstall couchdb
```

Download the application from http://couchdb.apache.org/#download, launch Fauxton, and check your installation.

Copy [this file](https://github.com/apache/couchdb/blob/master/rel/overlay/bin/couchup) into your filesystem, make it executable, and run it:

```bash
chmod +x couchup.py
./couchup.py -h
```

You might need Python 3, pip3, and:

```bash
pip3 install requests progressbar2
```

Move your `.couch` files into the specified `database_dir` in your [Fauxton config](http://127.0.0.1:5984/_utils/#_config/couchdb@localhost), then:

```bash
./couchup list           # Shows your unmigrated 1.x databases
./couchup replicate -a   # Replicates your 1.x DBs to 2.x
./couchup rebuild -a     # Optional; starts rebuilding your views
./couchup delete -a      # Deletes your 1.x DBs (careful!)
./couchup list           # Should show no remaining databases!
```
