module ActionView
  module Helpers
    module FormTagHelper

      # Creates a honeypot on forms
      # By default it creates a <div> that wraps around a <label> and
      # <input type="text">. Can also use it as a content_tag that will
      # allow you to do more exotic layouts.
      #
      # Examples
      #
      # = honeypot_field_tag
      #
      # <div>
      #   <label for="pseudo_random_field_name">
      #   <input type="text" name="pseudo_random_field_name" id="pseudo_random_field_name">
      # </div>
      #
      # = honeypot_field_tag(:label) do |name|
      #   = check_box_tag(:do_not_check, name, false, class: 'mead-input-attributes')
      #
      # <label class="mead-label-attributes">
      #   <input id="name", name="name", type="checkbox", value="false">
      # </label>
      def mead_honeypot_tag(options = {}, tag: nil, name: nil, value: nil, &block)
        options = options.stringify_keys
        label_options = options.delete('label_options') || {}
        wrapper_options = options.delete('wrapper_options') || {}

        name ||= mead_field_name
        tag ||= :div

        if block_given?
          content_tag(tag, options, &block)
        else
          label = label_tag(name, name.titleize, mead_label_attributes.merge(label_options))
          field = text_field_tag(name, value, mead_input_attributes.merge(options))

          content_tag(tag, label + field, mead_wrapper_attributes.merge(wrapper_options))
        end
      end

      # Obfuscates the name of a field and provides the name to a block.
      #
      # Examples
      # = mead_obfuscate_tag(:first_name) do |first_name|
      #   = label_tag first_name
      #   = text_field_tag first_name
      #
      # <label for="obfuscated_first_name">
      # <input name="obfuscated_fist_name" id="obfuscated_first_name" type="text">
      #
      # By default it creates a text_field_tag and obfuscates the name of the field.
      def mead_obfuscate_tag(name, &block)
        capture(mead_obfuscate_field(name), &block)
      end
    end
  end
end
