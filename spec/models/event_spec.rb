# frozen_string_literal: true

# == Schema Information
#
# Table name: events
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
  let(:current_time) { Time.zone.local(2026, 8, 8, 12, 0, 0) }
  let(:state) do
    State.create!(
      name:         'California',
      symbol:       'CA',
      fips_code:    6,
      is_territory: 0,
      lat_min:      32.30,
      lat_max:      40.00,
      long_min:     114.8,
      long_max:     124.24
    )
  end
  let(:county) { state.counties.create!(name: 'Alameda', fips_code: 1, fips_class: 'H1') }
  let(:valid_event_attributes) do
    {
      name:        'Community Meeting',
      description: 'Planning meetup',
      county:      county,
      start_time:  current_time + 1.hour,
      end_time:    current_time + 2.hours
    }
  end

  def event_with_times(start_time, end_time)
    described_class.new(valid_event_attributes.merge(start_time: start_time, end_time: end_time))
  end

  def expect_invalid_start_time(start_time, end_time)
    event = event_with_times(start_time, end_time)

    expect(event).not_to be_valid
    expect(event.errors[:start_time]).to include('must be after today')
  end

  def expect_invalid_end_time(start_time, end_time)
    event = event_with_times(start_time, end_time)

    expect(event).not_to be_valid
    expect(event.errors[:end_time]).to include('must be after start time')
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:start_time) }
    it { is_expected.to validate_presence_of(:end_time) }
    it { is_expected.to belong_to(:county) }

    it 'accepts future events' do
      travel_to current_time do
        event = described_class.new(valid_event_attributes)

        expect(event).to be_valid
      end
    end

    it 'does not accept events that are already in progress' do
      travel_to current_time do
        expect_invalid_start_time(current_time - 30.minutes, current_time + 30.minutes)
      end
    end

    it 'does not accept events that already happened' do
      travel_to current_time do
        expect_invalid_start_time(current_time - 2.hours, current_time - 1.hour)
      end
    end

    it 'does not accept events with end times before start times' do
      travel_to current_time do
        expect_invalid_end_time(current_time + 2.hours, current_time + 1.hour)
      end
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

    it 'returns empty hash when state is nil' do
      @ca_state_double = nil

      expect(@event.county_names_by_id).to eq({})
    end

    it 'returns empty hash when county is nil' do
      @alameda_county_doub = nil

      expect(@event.county_names_by_id).to eq({})
    end
  end
end
