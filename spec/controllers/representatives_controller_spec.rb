# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RepresentativesController do
  render_views

  describe 'GET show' do
    let(:representative) do
      Representative.create!(
        name: 'John Doe',
        title: 'Senator',
        ocdid: '12345'
      )
    end

    it 'returns a successful response' do
      get :show, params: { id: representative.id }

      expect(response).to be_successful
    end

    it 'assigns the requested representative' do
      get :show, params: { id: representative.id }

      expect(assigns(:representative)).to eq(representative)
    end

    it 'renders the representative profile' do
      get :show, params: { id: representative.id }

      expect(response.body).to include('John Doe')
      expect(response.body).to include('Senator')
    end

    it 'displays the representative photo when available' do
      representative.update!(photo_url: 'https://www.congress.gov/img/member/d000001_200.jpg')
      get :show, params: { id: representative.id }

      expect(response.body).to include(representative.photo_url)
    end

    it 'renders successfully when optional profile fields are missing' do
      get :show, params: { id: representative.id }

      expect(response).to be_successful
      expect(response.body).not_to include('<img')
      expect(response.body).not_to include('Contact Form')
    end
  end
end
