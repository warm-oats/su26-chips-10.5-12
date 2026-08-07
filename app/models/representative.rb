# frozen_string_literal: true

# == Schema Information
#
# Table name: representatives
#
#  id               :integer          not null, primary key
#  address          :string
#  birthday         :date
#  contact_form_url :string
#  facebook         :string
#  gender           :string
#  name             :string
#  ocdid            :string
#  party            :string
#  phone            :string
#  photo_url        :string
#  title            :string
#  twitter          :string
#  website          :string
#  youtube          :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  bioguide_id      :string
#
class Representative < ApplicationRecord
  has_many :news_items, dependent: :delete_all

  # Review the Geocodio docs
  # https://www.geocod.io/docs/#congressional-districts
  def self.geocodio_search(query)
    geocodio_api_key = ENV.fetch('GEOCODIO_API_KEY', Rails.application.credentials[:GEOCODIO_API_KEY])
    raise ArgumentError, 'Missing GEOCODIO_API_KEY' if geocodio_api_key.blank?

    geocodio = Geocodio::Gem.new(geocodio_api_key)
    geocodio.geocode(query, ['cd'])
  end

  # NOTE: This info only grabs data for the most likely represenative district
  # given a search. It would be good to adapt this to show all possible
  # matching representatives for a search / county.
  # See https://www.geocod.io/docs/#data-appends-fields
  def self.civic_api_to_representative_params(rep_info)
    return [] if rep_info.blank?

    reps = []
    response = rep_info['results'][0]['response']
    fields = response['results'][0]['fields']
    @legislators = fields['congressional_districts'][0]['current_legislators']

    @legislators.each_with_index do |official, _index|
      official['name'] = "#{official.dig('bio', 'first_name')} #{official.dig('bio', 'last_name')}"
      title = official['type']
      # Inspect all the data that's there to make part 1 easier.
      # Rails.logger.debug official
      # official.dig('bio', 'party')
      ocdid = official.dig('references', 'govtrack_id')
      reps << Representative.find_rep(official, ocdid: ocdid, title: title)
    end
    
    reps
  end

  def self.find_rep(official, title: '', ocdid: '')
    raise ArgumentError unless official.is_a?(Hash)
    raise ArgumentError if !title.is_a?(String) || !ocdid.is_a?(String)

    rep = Representative.find_or_initialize_by(
      name: official['name'],
      ocdid: ocdid
    )
    
    rep.update_from_geocodio(official, title, ocdid)
  end

  def update_from_geocodio(official, title, ocdid)
    self.title = title
    self.ocdid = ocdid

    update_bio(official['bio'] || {})
    update_contact(official['contact'] || {})
    update_social(official['social'] || {})
    update_references(official['references'] || {})

    save!
    self
  end

  def update_bio(bio)
    self.party = bio['party']
    self.birthday = bio['birthday']
    self.gender = bio['gender']
    self.photo_url = bio['photo_url']
  end

  def update_contact(contact)
    self.address = contact['address']
    self.phone = contact['phone']
    self.contact_form_url = contact['contact_form']
    self.website = contact['url']
  end

  def update_social(social)
    self.twitter = social['twitter']
    self.facebook = social['facebook']
    self.youtube = social['youtube']
  end

  def update_references(references)
    self.bioguide_id = references['bioguide_id']
  end
end
