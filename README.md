# MiniCheck

MiniCheck provides a simple Rack application for adding simple health checks to your app.
The JSON output is similar to the one provided by the [Metrics](http://metrics.codahale.com/) Java library.
It was started at [Workshare ltd.](http://www.workshare.com) as an easy way of providing monitoring to our Rack based applciations.

[![Gem Version](https://badge.fury.io/rb/mini_check.png)](http://badge.fury.io/rb/mini_check)
[![Build Status](https://secure.travis-ci.org/workshare/mini-check.png)](http://travis-ci.org/workshare/mini-check) 
[![Code Climate](https://codeclimate.com/github/workshare/mini-check.png)](https://codeclimate.com/github/workshare/mini-check)

## Quick Start

Install the gem with the usual `gem install mini_check`.
Build a new Rack app and register some checks

```ruby
MyHealthCheck = MiniCheck::RackApp.new(path: '/healthcheck')
MyHealthCheck.register('health.redis_client'){ MyApp.redis_client.connected? }
MyHealthCheck.register('health.db_connection'){ MyApp.db_connection.fetch('show tables').to_a }
```

Mount it in your `config.ru`:

```ruby
use MyHealthCheck
run MyApp
```

If you now visit `http://localhost:XXXX/healthcheck` you should get something like:

```json
{
  "health.db_connection": {
    "healthy": true
  },
  "health.redis_client": {
    "healthy": true
  }
}
```

The registered lambdas should do any of the following things:

* Return true if the check was successful.
* Return false if not.
* Raise an exception which will be understood as not healthy. Find an example of the output below:

```json
{
  "health.db_connection": {
    "healthy": false,
    "error": {
      "message": "Mysql2::Error: MySQL server has gone away",
      "stack": [
        "/home/manuel/sd/my_app/vendor/bundle/ruby/1.9.1/gems/sequel-4.7.0/lib/sequel/adapters/mysql2.rb:77:in `query'",
        "/home/manuel/sd/my_app/vendor/bundle/ruby/1.9.1/gems/sequel-4.7.0/lib/sequel/adapters/mysql2.rb:77:in `block in _execute'",
        "/home/manuel/sd/my_app/vendor/bundle/ruby/1.9.1/gems/sequel-4.7.0/lib/sequel/database/logging.rb:37:in `log_yield'",
        "..."
      ]
    }
  },
  "health.redis_client": {
    "healthy": true
  }
}
```

The http status code will be 200 if all checks are healthy and 500 otherwise.

## Version

```ruby
MyVersionCheck = MiniCheck::VersionRackApp.new(name: 'Cards', path: '/admin/version', build_file: './config/build.yml').tap do |app|
    app.metadata["Whatever Here"] = "Bla Bla"
    ...
end
```

The build_file can be a YML or a plain text file. It needs to have pairs key-values.

If you now visit `http://localhost:XXXX/admin/version.json` you should get something like:

```json
{
  "Application Name": "Cards",
  "Whatever Here": "Bla Bla"
}
```

If you now visit `http://localhost:XXXX/admin/version` you should get something like:

```
  Application Name=Cards
  Whatever Here=Bla Bla
```

## Maintaining

Here is a good tutorial on this: 
[Developing a RubyGem using Bundler](https://github.com/radar/guides/blob/master/gem-development.md).

## License

Released under the MIT License.  See the [LICENSE](LICENSE.md) file for further details.

