# Logplex

Publish and Consume Logplex messages

Logplex is the Heroku log router, and can be found [here](https://github.com/heroku/logplex).

### Publishing messages

```ruby
publisher = Logplex::Publisher.new(logplex_token, logplex_url)
publisher.publish("This is a log entry")
```

Passing an array of messages to the `#publish` method will publish them all in one request,
so some latency optimization is possible:

```ruby
publisher.publish [ "And as we wind on down the road",
                    "Our shadows taller than our soul",
                    "There walks a lady we all know",
                    "Who shines white light and wants to show"]
```

### Consumnig messages

TBD

## Configuration

You can configure default values for logplex message posting:

```ruby
Logplex.configure do |config|
  config.logplex_url = 'https://logplex.example.com'
end
```

In the example above, it is now not not necessary to
specify a logplex URL when getting a hold of a publisher:

```ruby
publisher = Logplex::Publisher.new(logplex_token)
```

### License

Copyright (c) Harold Giménez. Released under the terms of the MIT License found in the LICENSE file.
