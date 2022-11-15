module ActionView
  module Helpers
    module FormHelper
      include Mead::Obfuscator

      # Creates a honeypot on forms that will be appropriately namespaced
      #
      # Examples
      #
      # = mead_honeypot(:text_field, :user)
      # # <input type="text" name="user[honeypot]" id=user_honeypot">
      #
      # = mead_honeypot(:text_field, :user) do |honeypot, name|
      #   = label(:user, name)
      #   = honeypot
      # # <label for="name">
      # # <input type="text" name="user[name]" id="user_name">
      def mead_honeypot(as_tag, object_name, name = nil, options = {}, &block)
        defaults = {value: nil}.merge(mead_input_attributes).merge(options)
        name ||= mead_field_name
        as_tag = :text_field unless [:text_field, :text_area].include?(as_tag)

        html = tag_class(as_tag).new(object_name, name, self, defaults).render
        if block_given?
          capture(html, name, &block)
        else
          html
        end
      end

      def mead_obfuscate(input_type, object_name, method, options = {})
        real_name = method.to_s
        obfuscated_name = mead_obfuscate_field(real_name)
        options.merge!({
          obfuscated_name: obfuscated_name,
          type: input_type.to_s
        })

        Tags::ObfuscatedTag.new(object_name, real_name, self, options).render
      end

      def mead_obfuscator(input_type, method, options = {}, arg1 = nil, arg2 = nil)
        @template.public_send(:mead_obfuscator, input_type, @object_name, method, options, arg1, arg2)
      end

      def mead_obfuscator(input_type, object_name, method, options = {}, *args)
        method = method.to_s
        obfuscated_name = mead_obfuscate_field(method)
        options.merge!({
          obfuscated_name: obfuscated_name,
          type: input_type.to_s
        })

        args << options

        Tags::ObfuscatedTag.new(object_name, method, self, *args).render
      end

      private

      def tag_class(value)
        "ActionView::Helpers::Tags::#{value.to_s.camelize}".constantize
      end
    end

    module Tags
      class ObfuscatedTag < Base
        def initialize(object_name, method_name, template_object, checked_value_or_options = nil, unchecked_value = nil, options = {})

          options = checked_value_or_options if checked_value_or_options.is_a?(Hash)
          options = options.stringify_keys


          super(object_name, method_name, template_object, options)
        end

        def render
          options['type'] ||= 'text'
          options['value'] = options.fetch('value') { value_before_type_cast(object) }
          add_default_name_and_id(options)

          options.delete 'obfuscated_name'

          tag 'input', options
        end

        private

        def sanitized_method_name
          @sanitized_method_name ||= @options.stringify_keys['obfuscated_name']
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
      def mead_obfuscate(as_tag, method, options = {})
        @template.public_send(:mead_obfuscate, as_tag, @object_name, method, options)
      end

      def mead_honeypot(as_tag = nil, name = nil, options = {}, &block)
        @template.public_send(:mead_honeypot, as_tag, @object_name, name, options, &block)
      end

      def mead_obfuscator(input_type, method, options = {}, arg1 = nil, arg2 = nil)
        @template.public_send(:mead_obfuscator, input_type, @object_name, method, options, arg1, arg2)
      end
    end
  end
end
