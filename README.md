# Logplex

Publish and Consume Logplex messages

Logplex is the Heroku log router, and can be found
[here](https://github.com/heroku/logplex).

### Publishing messages

```ruby
publisher = Logplex::Publisher.new(logplex_token, logplex_url)
publisher.publish("There's a lady who's sure, all that glitters is gold",
                   process: 'worker.2', host: 'some-host')
```

Passing an array of messages to the `#publish` method will publish them all in
one request, so some latency optimization is possible:

```ruby
publisher.publish [ "And as we wind on down the road",
                    "Our shadows taller than our soul",
                    "There walks a lady we all know",
                    "Who shines white light and wants to show"]
```

The message can also be passed in the form of a Hash, in which case it is
formatted as machine readble key/value pairs suitable for metrics collection,
eg: [log2viz](https://blog.heroku.com/archives/2013/3/19/log2viz)

```ruby
publisher.publish { vocals: 'Robert Plant', guitar: 'Jimmy Page' }
# produces the message: vocals='Robert Plant' guitar='Jimmy Page'
```
### Consumnig messages

TBD

## Configuration

You can configure default values for logplex message posting:

```ruby
Logplex.configure do |config|
  config.logplex_url     = 'https://logplex.example.com'
  config.process         = 'stats'
  config.host            = 'host'
  config.publish_timeout = 2
end
```

In the example above, it is now not not necessary to specify a logplex URL,
process or host when getting a hold of a publisher and publishing messages:

```ruby
publisher = Logplex::Publisher.new(logplex_token)
publisher.publish "And she's buying a stairway to heaven"
```

### License

Copyright (c) Harold Giménez. Released under the terms of the MIT License found
in the LICENSE file.
