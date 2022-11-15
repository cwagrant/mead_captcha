# Mead

Mead is a simple honeypot gem and field name obfuscator.  It allows you to add a honeypot to any form as easily as calling `honeypot_field_tag`.

# Usage
### Honeypots
Generating a simple honeypot
```ruby
 honeypot_field_tag
  
 # => <div>
 #      <label for="pseudo_random_field_name">
 #      <input type="text" name="pseudo_random_field_name" id="pseudo_random_field_name">
 #    </div>
```

You can also get more creative by using it as a block to generate a content tag and nest your honeypot. This can allow you to make your honeypot blend in as seamlessly as you like to the DOM.
```ruby
honeypot_field_tag(:label) do |name|
  check_box_tag(:do_not_check, name, false, class: 'mead-input-attributes')
  
# => <label class="mead-label-attributes">
#      <input id="name", name="name", type="checkbox", value="false">
#    </label>
```

### Obfuscation
```ruby
mead_obfuscate_tag(:first_name) do |first_name|
  label_tag first_name
  text_field_tag first_name
  
# => <label for="obfuscated_first_name">
#    <input name="obfuscated_fist_name" id="obfuscated_first_name" type="text">
```

To deobfuscate your params you can call mead_params to get a hash returned of the deobfuscated values.

```ruby
def user_params
  params.
    require(:user).
    permit(:first_name, :last_name)
    .merge(mead_params)
end

user_params
# => {first_name: foo, last_name: bar, email: "foo@bar.com"}
```

In addition to the above form tag helpers, Mead also implements these tags as form helpers and form builders as well.




After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cwagrant/mead.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).


