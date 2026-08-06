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
require 'rails_helper'

RSpec.describe Representative do
  describe '.civic_api_to_representative_params' do
    before do
      @rep_res = described_class.create({ name: 'Donald Beyer', ocdid: '412657',
      title: 'representative' })

      @rep_info = JSON.parse(File.read('spec/geocodio_api_call_dump.json'))
      response = @rep_info['results'][0]['response']['results'][0]['fields']
      @official = response['congressional_districts'][0]['current_legislators'][0]

      allow(described_class).to receive(:find_rep).and_return(@rep_res)

      @result = described_class.civic_api_to_representative_params(@rep_info)
    end

    it 'returns array containing rep object' do
      expect(@result).to eq([@rep_res, @rep_res, @rep_res])
    end

    it 'returns empty array when given no data' do
      result_empty = described_class.civic_api_to_representative_params([])
      expect(result_empty).to be_empty
    end

    it 'calls .find_rep with correct args' do
      expect(described_class).to have_received(:find_rep).with(@official, title: 'representative', ocdid: '412657')
    end

    it 'returns array of rep objs with correct vals' do
      rep = @result[0]
      expect(rep.name).to eq('Donald Beyer')
      expect(rep.ocdid).to eq('412657')
      expect(rep.title).to eq('representative')
    end

    it 'returns non-empty arr with valid args' do
      expect(@result).not_to be_empty
    end
  end

  describe '.find_rep' do
    def find_rep
      described_class.find_rep(@official, title: 'representative', ocdid: '412657')
    end

    before do
      @rep_info = JSON.parse(File.read('spec/geocodio_api_call_dump.json'))
      @official = @rep_info['results'][0]['fields']['congressional_districts'][0]['current_legislators'][0]
      @official['name'] = "#{@official.dig('bio', 'first_name')} #{@official.dig('bio', 'last_name')}"
    end

    it 'raises ArgumentError for invalid args' do
      expect { described_class.find_rep(nil) }.to raise_error(ArgumentError)
      expect { described_class.find_rep(nil, 'Donald Beyer', '123456') }.to raise_error(ArgumentError)
      expect { described_class.find_rep('12345', @official, 'Donald Beyer') }.to raise_error(ArgumentError)
      expect { described_class.find_rep }.to raise_error(ArgumentError)
    end

    it 'saves rep if rep not in db' do
      expect { find_rep }
        .to change(described_class, :count).from(0).to(1)
    end

    it 'does not save duplicate reps' do
      expect { find_rep }
        .to change(described_class, :count).from(0).to(1)
      expect { find_rep }
        .not_to change(described_class, :count)
    end

    it 'returns correct rep object with properties' do
      rep = find_rep

      expect(rep.name).to eq('Donald Beyer')
      expect(rep.ocdid).to eq('412657')
      expect(rep.title).to eq('representative')
    end
  end
end
