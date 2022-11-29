module MeadCaptcha
  module Helpers
    def self.included(base)
      helper_methods = self.protected_instance_methods

      base.send :helper_method, helper_methods
    end

    def on_honeypot_failure
      head :ok if honeypot_present?
    end

    def honeypot_present?
      honeypot_params = params.permit!.to_hash

      honeypot_params.extend Hashie::Extensions::DeepFind

      honeypot_field_names.each do |honeypot|
        return true if honeypot_params.deep_find(honeypot).present?
      end

      false
    rescue StandardError => e
      false
    end

    def mead_params(masked = nil, parameterize: true)
      masked = if masked.nil?
                 params.permit!.to_hash
               elsif masked.is_a?(ActionController::Parameters)
                 masked.permit!.to_hash
               else
                 masked
               end

      unmasked = {}

      masked.map do |key, value|
        key = deobfuscate(key)
        if value.is_a? Hash
          value = mead_params(value, parameterize: false)
        elsif value.is_a? Array
          value = value.flat_map { |v| mead_params(v, parameterize: false) }
        end

        unmasked[key] = value
      end

      if parameterize
        ActionController::Parameters.new(unmasked)
      else
        unmasked
      end
    end

    protected
    # Each of the below methods can be overwritten. Of note are
    # the *_attributes methods which can be used to easily customize
    # the options of the <div>, <label>, and <input> fields.
    #
    # You can also provide your own custom list of honeypot field names
    # by writing your own honeypot_field_names method.

    def mead_field_name
      @mead_field_names ||= honeypot_field_names

      raise NoAvailableHoneypotFieldNames if @mead_field_names.empty?

      @mead_field_names.delete @mead_field_names.sample
    end

    def mead_wrapper_attributes
      {
        aria: { hidden: true},
        class: 'mead-style-attributes'
      }
    end

    def mead_input_attributes
      {
        aria: { hidden: true},
        class: 'mead-style-attributes',
        tabindex: -1
      }
    end

    def mead_label_attributes
      {
        aria: { hidden: true},
        tabindex: -1
      }
    end

    def honeypot_field_names
      %w(
        secret
        passphrase
        real_password
        a_password
        your_comments
        a_comment
      )
    end

    def mead_obfuscate_field(name)
      real_name = extract_name(name.to_s)
      encrypted = obfuscate(real_name)

      name.to_s.gsub(/#{real_name}/, encrypted)
    end

    private

    def obfuscate(value)
      hash = {value: value, random: SecureRandom.hex(12)}
      Base64.urlsafe_encode64(JSON.dump(hash)).tr('=', '')
    end

    def deobfuscate(value)
      hash = JSON.load(Base64.urlsafe_decode64(value))
      hash['value']
    rescue JSON::ParserError, ArgumentError
      value
    end

    def extract_name(name)
      real_name = name.scan(/\[[^\[\]]+\]/).last || name
      real_name.tr('[]', '')
    end
  end
end

# This will give access to the views/tags to any of the above needed public/protected methods.
ActionController::Base.send(:include, MeadCaptcha::Helpers) if defined?(ActionController::Base)
