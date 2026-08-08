# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventsController do
  before do
    @california = State.create!(
      name:         'California',
      symbol:       'CA',
      fips_code:    6,
      is_territory: 0,
      lat_min:      32.30,
      lat_max:      40.00,
      long_min:     114.8,
      long_max:     124.24
    )
    @oregon = State.create!(
      name:         'Oregon',
      symbol:       'OR',
      fips_code:    41,
      is_territory: 0,
      lat_min:      42.00,
      lat_max:      46.30,
      long_min:     116.46,
      long_max:     124.57
    )

    @alameda = @california.counties.create!(name: 'Alameda County', fips_code: 1, fips_class: 'H1')
    @los_angeles = @california.counties.create!(name: 'Los Angeles County', fips_code: 37, fips_class: 'H1')
    @multnomah = @oregon.counties.create!(name: 'Multnomah County', fips_code: 51, fips_class: 'H1')
    start_time = 1.week.from_now

    @alameda_event = Event.create!(
      name:        'Alameda Town Hall',
      description: 'Local policy discussion',
      county:      @alameda,
      start_time:  start_time,
      end_time:    start_time + 1.hour
    )
    @los_angeles_event = Event.create!(
      name:        'Los Angeles Rally',
      description: 'Community rally',
      county:      @los_angeles,
      start_time:  start_time,
      end_time:    start_time + 2.hours
    )
    @oregon_event = Event.create!(
      name:        'Portland Meetup',
      description: 'Volunteer meetup',
      county:      @multnomah,
      start_time:  start_time,
      end_time:    start_time + 3.hours
    )
  end

  describe 'GET index' do
    it 'lists all events without filters' do
      get :index

      expect(assigns(:events)).to contain_exactly(@alameda_event, @los_angeles_event, @oregon_event)
    end

    it 'filters events by state' do
      get :index, params: { 'filter-by' => 'state-only', 'state' => 'CA' }

      expect(assigns(:events)).to contain_exactly(@alameda_event, @los_angeles_event)
    end

    it 'filters events by county' do
      get :index, params: { 'filter-by' => 'county', 'state' => 'CA', 'county' => '001' }

      expect(assigns(:events)).to contain_exactly(@alameda_event)
    end
  end

  describe 'GET show' do
    it 'loads the requested event' do
      get :show, params: { id: @alameda_event.id }

      expect(response).to be_successful
      expect(assigns(:event)).to eq(@alameda_event)
    end
  end
end
