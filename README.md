# ReqWrap

Plain Ruby API client for testing and prototyping with simple environment
management. Supports encrypted environment definitions. Features optional
commandline interface and code generation.

## Installation

TODO: Replace
`UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG` with your
gem name right after releasing it to RubyGems.org. Please do not do it earlier
due to security reasons. Alternatively, replace this section with instructions
to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

## Usage

Simply subclass `ReqWrap::Req` to use the `HTTP` capabilities of the gem.

### Generate new request template

Simply execute after installing the gem: `req_wrap g my_request`

This will generate the `my_request.rb` file in the current folder with the
following request template:

```ruby
# frozen_string_literal: true

require 'req_wrap'

class MyRequest < ReqWrap::Req
  def call
    http.get('https://httpbin.org/ip')
  end
end

if __FILE__ == $PROGRAM_NAME
  my_request = MyRequest.new(logger: nil)

  my_request.load_env
  puts my_request.call
end
```

Simply change the definition of the `#call` method and the request can be
executed like any `Ruby` file: `ruby my_request.rb` which will make the actual
request and print the results.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake test` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and the created tag, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/vxd7/req_wrap

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
