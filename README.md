# Mead

Mead is a simple honeypot gem and field name obfuscator.  It allows you to add a honeypot to any form as easily as calling `honeypot_field_tag`.

In addition to honeypots you can obfuscate field names by including `Mead::Obfuscator` in your controller and then masking the fields in your view like so

```haml
  = text_field_tag mask_field(:first_name), @user.first_name, placeholder: 'First Name', required: true
```

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/mead`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mead'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install mead

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/mead.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).


