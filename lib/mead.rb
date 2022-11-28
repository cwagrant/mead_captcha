# frozen_string_literal: true

require 'mead/configuration'
require_relative 'mead/version'
require 'mead/form_tag_helper'
require 'mead/form_helper'
require 'mead/engine'
require 'mead/helpers'
require 'hashie'
require 'json'

class NoAvailableHoneypotFieldNames < StandardError; end

module Mead
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.included(base)
    helper_methods = self.protected_instance_methods

    base.send :helper_method, helper_methods

    if base.respond_to? :before_action
      base.send :prepend_before_action, :on_honeypot_failure, self.protect_controller_actions

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
