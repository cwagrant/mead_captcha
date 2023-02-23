# frozen_string_literal: true
require 'action_controller'

RSpec.describe MeadCaptcha do
  include RSpecHtmlMatchers

  it "has a version number" do
    expect(MeadCaptcha::VERSION).not_to be nil
  end

  context :helpers do
    before do
      @helpers = ActionView::TestCase::TestController.new.helpers
      @controller = ActionView::TestCase::TestController.new
      @controller.params = ActionController::Parameters.new({user: {first_name: 'foo', last_name: 'bar'}, eyJ2YWx1ZSI6Im9wdGlvbnMifQ: [ {id: 1, eyJ2YWx1ZSI6Im5hbWUifQ: 'Option1'}, {id: 2, name: 'Option2'} ]})
      @helpers = @controller.helpers
    end

    context :controller_helpers do
      it 'makes honeypot_present? available to controllers' do
        expect(ActionView::TestCase::TestController.new.respond_to?(:honeypot_present?)).to eq(true)
      end

      it 'returns true if a a honeypot is present' do
        @controller.params = ActionController::Parameters.new({
          "#{@helpers.honeypot_field_names.sample}" => 'test'
        })

        expect(@controller.honeypot_present?).to eq(true)
      end
    end

    it 'throws an error when you run out of honeypot names' do
      expect { 10.times { @helpers.mead_field_name } }.to raise_error(NoAvailableHoneypotFieldNames)
    end

    describe :mead_honeypot_tag do
      it 'creates a honeypot with a label' do
        allow_any_instance_of(ActionView::TestCase::TestController).to receive(:mead_field_name).and_return('honeypot')
        html = @helpers.mead_honeypot_tag
        expect(html).to have_tag("input[id=#{@helpers.mead_field_name}]")
        expect(html).to have_tag("label[for=#{@helpers.mead_field_name}]")
      end
    end

    describe :mead_obfuscate do
      let(:widget) { double }

      before do
        allow(widget).to receive(:foo).and_return('bar')
      end

      it 'creates an obfuscated field' do
        html = @helpers.mead_obfuscate(:text_box, :widget, :foo )
        expect(html).to have_tag("input[type=text_box]")
        expect(html).to have_tag("input[id^=widget]")
      end
    end
  end
end

