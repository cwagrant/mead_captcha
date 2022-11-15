module ActionView
  module Helpers
    module FormHelper
      include Mead::Obfuscator

      # Creates a honeypot on forms that will be appropriately namespaced
      #
      # ==== Examples
      #
      #   mead_honeypot(:text_field, :user)
      #   # => <input type="text" name="user[honeypot]" id=user_honeypot">
      #
      #   mead_honeypot(:text_field, :user) do |honeypot, name|
      #     label(:user, name)
      #     honeypot
      #   # => <label for="name">
      #   #    <input type="text" name="user[name]" id="user_name">
      def mead_honeypot(form_tag, object_name, name = nil, options = {}, &block)
        defaults = {value: nil}.merge(mead_input_attributes).merge(options)
        name ||= mead_field_name
        form_tag = :text_field unless [:text_field, :text_area].include?(form_tag)

        html = tag_class(form_tag).new(object_name, name, self, defaults).render

        if block_given?
          capture(html, name, &block)
        else
          html
        end
      end

      # Creates an obfuscation on forms that will be appropriately namespaced
      #
      # ==== Examples
      #
      #   mead_obfuscate(:checkbox, :user, :active)
      #   # => <input type="checkbox" name="user[foo]" id="user_foo">
      #
      #   mead_obfuscate(:checkbox, :user, :active) do |html, obfus_name, real_name|
      #     label(:user, obfus_name, real_name)
      #     html
      #   # => <label for="user_foo">Active</label>
      #   #    <input type="hidden" value="0" name="user[foo]" id="user_foo">
      #   #    <input type="checkbox" value="1" name="user[foo]" id="user_foo">
      def mead_obfuscate(input_type, object_name, method, options = {}, &block)
        real_name = method.to_s
        obfuscated_name = mead_obfuscate_field(real_name)
        options.merge!({
          obfuscated_name: obfuscated_name,
          type: input_type.to_s
        })

        html = Tags::ObfuscatedTag.new(object_name, real_name, self, options).render

        if block_given?
          capture(html, obfuscated_name, real_name.titleize, &block)
        else
          html
        end
      end

      private

      def tag_class(value)
        "ActionView::Helpers::Tags::#{value.to_s.camelize}".constantize
      end
    end

    module Tags
      class ObfuscatedTag < Base
        def render
          options = @options.stringify_keys
          options['type'] ||= 'text'

          if options['type'].to_s == 'checkbox'
            include_hidden = options.fetch('include_hidden') { true }
            options['value'] = options.fetch('value') { '1' }
            @unchecked_value = options.fetch('unchecked_value') { '0' }
          end

          options['value'] = options.fetch('value') { value_before_type_cast(object) }
          add_default_name_and_id(options)

          options.delete 'obfuscated_name'
          checkbox = tag 'input', options

          if include_hidden
            hidden = hidden_field_for_checkbox(options)
            hidden + checkbox
          else
            checkbox
          end
        end

        private

        def sanitized_method_name
          @sanitized_method_name ||= @options.stringify_keys['obfuscated_name']
        end

        def hidden_field_for_checkbox(options)
          @unchecked_value ? tag("input", options.slice("name", "disabled", "form").merge!("type" => "hidden", "value" => @unchecked_value)) : "".html_safe
       end
        # this is how it is done in some later versions
        # We may need to consider different ways of setting the tag_name and tag_id
        # independent of versions
        # def tag_name(multiple = false, index = nil)
          # obfuscated = @options.stringify_keys['obfuscated_name'] || sanitized_method_name
          # @template_object.field_name(@object_name, obfuscated, multiple: multiple, index: index)
        # end

        # def tag_id(index = nil, namespace = nil)
          # obfuscated = @options.stringify_keys['obfuscated_name'] || @method_name
          # @template_object.field_id(@object_name, obfuscated, index: index, namespace: namespace)
        # end
      end
    end

    class FormBuilder
      def mead_obfuscate(form_tag, method, options = {}, &block)
        @template.public_send(:mead_obfuscate, form_tag, @object_name, method, options, &block)
      end

      def mead_honeypot(form_tag = nil, name = nil, options = {}, &block)
        @template.public_send(:mead_honeypot, form_tag, @object_name, name, options, &block)
      end
    end
  end
end
