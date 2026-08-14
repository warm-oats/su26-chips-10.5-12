# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CurrentsNewsClient do
  def article(number)
    {
      'title'       => "Article #{number}",
      'url'         => "https://example.com/articles/#{number}",
      'description' => "Description #{number}"
    }
  end

  def stub_currents_response(news:, status: 'ok', success: true)
    body = { 'status' => status, 'news' => news }.to_json
    response = instance_double(Faraday::Response, success?: success, status: 200, body: body)
    allow(Faraday).to receive(:get).and_return(response)
  end

  describe '#search' do
    it 'returns normalized top five articles for an issue' do
      stub_currents_response(news: (1..6).map { |number| article(number) })

      results = described_class.new(api_key: 'test-key').search('Climate Change')

      expect(results.length).to eq(5)
      expect(results.first).to eq(title: 'Article 1', url: 'https://example.com/articles/1',
                                  description: 'Description 1')
    end

    it 'requests Currents with the issue keyword and page size' do
      stub_currents_response(news: [article(1)])

      described_class.new(api_key: 'test-key').search('Climate Change')

      expect(Faraday).to have_received(:get).with(
        described_class::SEARCH_URL,
        hash_including(keywords: 'Climate Change', page_size: 5, apiKey: 'test-key')
      )
    end

    it 'raises when the API key is missing' do
      expect { described_class.new(api_key: '').search('Climate Change') }
        .to raise_error(ArgumentError, 'Missing CURRENTS_API_KEY')
    end

    it 'raises when Currents returns an error response' do
      stub_currents_response(news: [], status: 'error')

      expect { described_class.new(api_key: 'test-key').search('Climate Change') }
        .to raise_error(CurrentsNewsClient::Error)
    end
  end
end
