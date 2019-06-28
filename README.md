# SimplySerializable

[![Build Status](https://travis-ci.org/ryanwjackson/simply_serializable.svg?branch=master)](https://travis-ci.org/ryanwjackson/simply_serializable) [![Coverage Status](https://coveralls.io/repos/github/ryanwjackson/simply_serializable/badge.svg?branch=master)](https://coveralls.io/github/ryanwjackson/simply_serializable?branch=master)

SimplySerializable (SS) is a lightweight gem for serializing objects.  It does not follow the JSON API structure, so as to optimizing for cycles and speed.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simply_serializable'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simply_serializable

## Usage

You can call `SimplySerializable::Serializer` directly or using the mixin on any object like so:

```ruby
module SimplySerializable
  class MixinTestObject
    include SimplySerializable::Mixin

    attr_reader :it_will_use_this_attr

    serialize attributes: %i[foo],
              except: %i[bar]

    def initialize
      @it_will_use_this_attr = 'This will be included in serialization.'
    end

    def bar
      'This IS NOT included via `except` above.'
    end

    def foo
      'This is included via `attributes` above.'
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ryanwjackson/simply_serializable. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SimplySerializable project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ryanwjackson/simply_serializable/blob/master/CODE_OF_CONDUCT.md).
