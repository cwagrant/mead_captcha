# frozen_string_literal: true

require_relative "mead/version"
require 'mead/obfuscator'
require 'mead/form_tag_helper'
require 'mead/form_helper'
require 'mead/engine'

class NoAvailableHoneypotFieldNames < StandardError; end

module Mead
  include Mead::Obfuscator

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

  protected

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
end

ActionController::Base.send(:include, Mead) if defined?(ActionController::Base)
