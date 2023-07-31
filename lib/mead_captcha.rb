# frozen_string_literal: true

require 'mead_captcha/configuration'
require_relative 'mead_captcha/version'
require 'mead_captcha/form_tag_helper'
require 'mead_captcha/form_helper'
require 'mead_captcha/engine'
require 'mead_captcha/helpers'
require 'hashie'
require 'json'

class NoAvailableHoneypotFieldNames < StandardError; end

module MeadCaptcha
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)

    ActionController::Base.send(:include, MeadCaptcha) if defined?(ActionController::Base)
  end

  def self.included(base)
    helper_methods = self.protected_instance_methods

    base.send :helper_method, helper_methods

    if base.respond_to? :before_action
      base.send :prepend_before_action, :on_honeypot_failure, **self.protect_controller_actions

    elsif base.respond_to? :before_filter
      base.send :prepend_before_filter, :on_honeypot_failure, self.protect_controller_actions
    end
  end

  def self.protect_controller_actions
    options = {}

    if configuration.protect_controller_actions.present?
      options[:only] = configuration.protect_controller_actions
    elsif configuration.ignore_controller_actions.present?
      options[:except] = configuration.ignore_controller_actions
    end

    options
  end
end
