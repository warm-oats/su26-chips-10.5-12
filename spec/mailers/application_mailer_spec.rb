# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationMailer do
  describe 'configurations' do
    it 'uses the correct default email' do
      expect(described_class.default_params[:from]).to eq('from@example.com')
    end

    it 'uses the correct layout' do
      expect(described_class._layout).to eq('mailer')
    end
  end
end
