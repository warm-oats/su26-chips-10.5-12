# frozen_string_literal: true

def escape_uri_component(value)
  CGI.escape(value).gsub('+', '%20')
end

Given /the Geocodio lookup for "(.*)" returns representatives/i do |query|
  representatives = [
    Representative.create!(
      name: 'Jane County',
      title: 'Representative',
      ocdid: 'county-search-test'
    )
  ]

  original_geocodio_search = Representative.method(:geocodio_search)
  original_parser = Representative.method(:civic_api_to_representative_params)

  Representative.define_singleton_method(:geocodio_search) do |address|
    decoded_address = CGI.unescape(address.to_s)
    raise "Unexpected geocodio query: #{decoded_address}" unless decoded_address == query

    :stubbed_geocodio_response
  end

  Representative.define_singleton_method(:civic_api_to_representative_params) do |response|
    unless response == :stubbed_geocodio_response
      raise "Unexpected geocodio response: #{response.inspect}"
    end

    representatives
  end

  @representative_search_restore = lambda do
    Representative.define_singleton_method(:geocodio_search) do |*args, **kwargs, &block|
      original_geocodio_search.call(*args, **kwargs, &block)
    end
    Representative.define_singleton_method(
      :civic_api_to_representative_params
    ) do |*args, **kwargs, &block|
      original_parser.call(*args, **kwargs, &block)
    end
  end
end

When /I visit the representative search for "(.*)"/i do |query|
  visit "/search/#{escape_uri_component(query)}"
end

After do
  @representative_search_restore&.call
end
