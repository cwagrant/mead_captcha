# frozen_string_literal: true

require 'pry'
require 'rails'
require 'active_support'
require 'action_view'
require 'action_controller'
require 'active_record'
require 'rspec-html-matchers'
require "mead_captcha"

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  # config.disable_monkey_patching!

  # Requires supporting files with custom matchers and macros, etc,
  # in ./support/ and its subdirectories.
  Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

class TestController < ActionController::Base
  include MeadCaptcha
  def index; end
end

class TestView < ActionView::Base
  attr_reader :controller

  def initialize(controller_path = nil, action = nil)
    @controller = TestController.new
  end
end

class TestWidget
  attr_accessor :foo
end

