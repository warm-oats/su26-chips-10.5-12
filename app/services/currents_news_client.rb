# frozen_string_literal: true

class CurrentsNewsClient
  SEARCH_URL = 'https://api.currentsapi.services/v1/search'

  class Error < StandardError; end

  def initialize(api_key: nil)
    @api_key = api_key
  end

  def search(issue)
    raise ArgumentError, 'Missing issue' if issue.blank?
    raise ArgumentError, 'Missing CURRENTS_API_KEY' if api_key.blank?

    response = Faraday.get(SEARCH_URL, request_params(issue))
    raise Error, "Currents API request failed with status #{response.status}" unless response.success?

    parse_news(response.body)
  end

  private

  def api_key
    return @api_key unless @api_key.nil?

    ENV.fetch('CURRENTS_API_KEY', Rails.application.credentials[:CURRENTS_API_KEY])
  end

  def request_params(issue)
    {
      keywords:    issue,
      language:    'en',
      page_number: 1,
      page_size:   5,
      apiKey:      api_key
    }
  end

  def parse_news(body)
    data = JSON.parse(body)
    raise Error, 'Currents API returned an error' unless data['status'] == 'ok'

    data.fetch('news', []).first(5).filter_map { |article| normalize_article(article) }
  rescue JSON::ParserError => e
    raise Error, "Currents API returned invalid JSON: #{e.message}"
  end

  def normalize_article(article)
    return if article['url'].blank?

    {
      title:       article['title'].presence || 'Untitled article',
      url:         article['url'],
      description: article['description'].to_s
    }
  end
end
