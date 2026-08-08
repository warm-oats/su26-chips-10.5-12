# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationJob do
  it 'inherits from base of ActiveJob' do
    expect(described_class).to be < ActiveJob::Base
  end
end
