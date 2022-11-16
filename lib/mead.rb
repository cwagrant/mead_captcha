# frozen_string_literal: true

require_relative "mead/version"
require 'mead/form_tag_helper'
require 'mead/form_helper'
require 'mead/engine'

class NoAvailableHoneypotFieldNames < StandardError; end

module Mead
  def self.included(base)
    helper_methods = self.protected_instance_methods

    base.send :helper_method, helper_methods
  end

  def honeypot_present?(requires: nil)
    # Accepts a singular requires or an array of requires to get
    # into more nested structures - by default we just permit
    # honeypot params directly
    #
    # e.g. requires: [:checkout, :user] is equivalent to calling
    # params.require(:checkout).require(:user).permit(honeypot_field_names)

    dirty = params

    if requires.is_a? Array
      dirty = requires.reduce(params) { |acc, requirement| acc.require(requirement) }
    elsif requires.present?
      dirty = dirty.require(requires)
    end

    honeypots = dirty.permit(honeypot_field_names)

    return false if honeypots.nil?

    honeypots.values.any?(&:present?)
  rescue
    false
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
      comments
      secret
      full_name
      passphrase
      real_password
    )
  end

  def mead_obfuscate_field(name)
    real_name = extract_name(name.to_s)
    encrypted = obfuscate_value(real_name)

    name.to_s.gsub(/#{real_name}/, encrypted)
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

ActionController::Base.send(:include, Mead) if defined?(ActionController::Base)
