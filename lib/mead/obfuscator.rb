module Mead
  module Obfuscator

    def mead_obfuscate_field(name)
      real_name = extract_name(name.to_s)
      encrypted = obfuscate_value(real_name)

      name.to_s.gsub(/#{real_name}/, encrypted)
    end

    def mead_params(requires: nil)
      masked = params

      if requires.is_a? Array
        masked = requires.reduce(params) { |acc, requirement| acc.require(requirement) }
      elsif requires.present?
        masked = masked.require(requires)
      end

      masked.permit!.reduce({}) do |acc, masked_value|
        decrypted = deobfuscate_value(masked_value.first)
        next acc if decrypted.nil?

        acc[decrypted] = masked_value.last

        acc
      end
    end

    private

    def obfuscate_value(value)
      hash = {value: value, random: SecureRandom.hex(12)}
      Base64.urlsafe_encode64(JSON.dump(hash))
    end

    def deobfuscate_value(value)
      hash = JSON.load(Base64.urlsafe_decode64(value))
      hash['value']
    rescue
      nil
    end

    def extract_name(name)
      real_name = name.scan(/\[[^\[\]]+\]/).last || name
      real_name.tr('[]', '')
    end
  end
end
