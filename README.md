# autoargs

autoargs automatically parses command-line arguments given a method by inspecting its signature.

```ruby
# test.rb
require 'autoargs'

def main(foo, bar='bar', baz: 'baz')
    puts(foo, bar, baz)
end

Autoargs::run(method(:main))

# $ ruby test.rb one two --baz three
# one
# two
# three
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'autoargs'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install autoargs

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).
