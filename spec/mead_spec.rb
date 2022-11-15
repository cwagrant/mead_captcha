# frozen_string_literal: true
require 'action_controller'

RSpec.describe Mead do
  include RSpecHtmlMatchers

  it "has a version number" do
    expect(Mead::VERSION).not_to be nil
  end

  it 'makes honeypot_present? available to controllers' do
    expect(ActionView::TestCase::TestController.new.respond_to?(:honeypot_present?)).to eq(true)
  end

  it 'throws an error when you run out of honeypot names' do
    @helpers = ActionView::TestCase::TestController.new.helpers
    expect { 10.times { @helpers.mead_field_name } }.to raise_error(NoAvailableHoneypotFieldNames)
  end

  context :form_tag_helpers do
    before do
      @helpers = ActionView::TestCase::TestController.new.helpers
      allow_any_instance_of(ActionView::TestCase::TestController).to receive(:mead_field_name).and_return('honeypot')
    end
    describe :mead_honeypot_tag do
      it 'creates a honeypot with a label' do
        html = @helpers.mead_honeypot_tag
        expect(html).to have_tag("input[id=#{@helpers.mead_field_name}]")
        expect(html).to have_tag("label[for=#{@helpers.mead_field_name}]")
      end
    end
  end
end
