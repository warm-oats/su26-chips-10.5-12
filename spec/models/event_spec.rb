# frozen_string_literal: true

# == Schema Information
#
# Table name: representatives
#
# t.string "name",          not null
# t.text "description"
# t.integer "county_id",    not null
# t.datetime "start_time"
# t.datetime "end_time"
# t.datetime "created_at",  not null
# t.datetime "updated_at",  not null
# t.index ["county_id"], name: "index_events_on_county_id"

require 'rails_helper'
require 'shoulda/matchers'

RSpec.describe Event do
  before do
    @past_time = Time.zone.parse('2010-01-01 8:30:00')
    @future_time = Time.zone.parse('2010-01-01 8:32:00')
    @start_time = Time.zone.parse('2010-01-01 8:31:00')
    @end_time = Time.zone.parse('2010-01-01 9:30:00')

    travel_to @start_time do
      @event = described_class.new(start_time: @start_time, end_time: @end_time)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:start_time) }
    it { is_expected.to validate_presence_of(:end_time) }
    it { is_expected.to belong_to(:county) }

    it 'does not accept events currently happening' do
      expect(@event).not_to be_valid
      expect(@event.errors[:start_time]).to include('must be after today')
    end

    it 'does not accept events that already happened' do
      @event.start_time = @past_time

      expect(@event).not_to be_valid
      expect(@event.errors[:start_time]).to include('must be after today')
    end

    it 'does not accept events with end times before start times' do
      @event.start_time = @future_time
      @event.end_time = @start_time

      expect(@event).not_to be_valid
      expect(@event.errors[:end_time]).to include('must be after start time')
    end
  end

  describe '.county_names_by_id' do
    before do
      @alameda_county_doub = instance_double(County, name: 'Alameda', id: 1, state_id: 1)
      @la_county_doub = instance_double(County, name: 'Los Angeles', id: 2, state_id: 1)
      @santa_clara_county_doub = instance_double(County, name: 'Santa Clara', id: 3, state_id: 1)
      @ca_state_double = instance_double(State,
                                         counties: [@alameda_county_doub, @la_county_doub, @santa_clara_county_doub],
                                         id: 1)
      @event = described_class.new(name: 'The Weeknds', county_id: 1)

      allow(@event).to receive(:county) do
        @alameda_county_doub
      end
      allow(@alameda_county_doub).to receive(:state) do
        @ca_state_double
      end
      allow(@ca_state_double).to receive(:counties).and_return(@ca_state_double.counties)
    end

    it 'calls county method' do
      @event.county_names_by_id

      expect(@event).to have_received(:county)
    end

    it 'returns the correct county hash' do
      expect(@event.county_names_by_id).to eq({ 'Alameda' => 1, 'Los Angeles' => 2, 'Santa Clara' => 3 })
    end

    it 'returns empty array when state is nil' do
      @ca_state_double = nil

      expect(@event.county_names_by_id).to eq({})
    end

    it 'returns empty array when county is nil' do
      @alameda_county_doub = nil

      expect(@event.county_names_by_id).to eq({})
    end
  end
end
