# ReqWrap

Plain Ruby API client for testing and prototyping with simple environment
management. Supports encrypted environment definitions. Features optional
commandline interface and code generation.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add req_wrap
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install req_wrap
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

The gem provides several quality of life methods which can be used to simplify
working with requests and responses. Some of these are:

- `#load_env` -- load the request environment
- `#response` -- reference to the latest `HTTP` response
- `#executed_request` -- reference to the latest executed `HTTP` request
- `#responses` -- `Ruby` array with the list of all `HTTP` responses
- `#save_response` -- save given (or last by default) response to current directory

Additionally, see the `ReqWrap::Req` file definition.

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
