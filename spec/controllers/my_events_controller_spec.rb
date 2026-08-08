# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MyEventsController do
  before do
    @user = User.create!(uid: 'user-1', provider: :github)
    @state = State.create!(
      name:         'California',
      symbol:       'CA',
      fips_code:    6,
      is_territory: 0,
      lat_min:      32.30,
      lat_max:      40.00,
      long_min:     114.8,
      long_max:     124.24
    )
    @county = @state.counties.create!(name: 'Alameda County', fips_code: 1, fips_class: 'H1')
    session[:user_id] = @user.id
  end

  def event_params(name: 'Community Meeting')
    start_time = 1.week.from_now
    {
      name:        name,
      description: 'Planning meetup',
      county_id:   @county.id,
      start_time:  start_time,
      end_time:    start_time.advance(hours: 1)
    }
  end

  def invalid_event_params
    event_params.merge(start_time: 1.day.ago, end_time: 23.hours.ago)
  end

  def create_event
    Event.create!(event_params(name: 'Existing Event'))
  end

  describe 'GET new' do
    it 'redirects guests to login' do
      session.delete(:user_id)

      get :new

      expect(response).to redirect_to(login_url)
    end

    it 'builds a new event for logged-in users' do
      get :new

      expect(assigns(:event)).to be_a_new(Event)
    end
  end

  describe 'POST create' do
    it 'creates an event and redirects to the events list' do
      expect { post :create, params: { event: event_params } }
        .to change(Event, :count).by(1)
      expect(response).to redirect_to(events_path)
    end

    it 'renders the form again when the event is invalid' do
      post :create, params: { event: invalid_event_params }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH update' do
    it 'updates an event and redirects to the events list' do
      event = create_event

      patch :update, params: { id: event.id, event: event_params(name: 'Updated Event') }

      expect(response).to redirect_to(events_path)
      expect(event.reload.name).to eq('Updated Event')
    end

    it 'renders edit again when the update is invalid' do
      event = create_event

      patch :update, params: { id: event.id, event: invalid_event_params }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the event and redirects to the events list' do
      event = create_event

      expect { delete :destroy, params: { id: event.id } }
        .to change(Event, :count).by(-1)
      expect(response).to redirect_to(events_url)
    end
  end
end
