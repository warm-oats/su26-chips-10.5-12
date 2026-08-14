# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MyNewsItemsController do
  before do
    @user = User.create!(uid: 'user-1', provider: :github)
    @representative = Representative.create!(name: 'Jane Doe', title: 'Representative', ocdid: 'rep-1')
    @article = {
      title:       'Climate Story',
      url:         'https://example.com/climate-story',
      description: 'Climate article summary'
    }
    session[:user_id] = @user.id
  end

  def search_params
    {
      representative_id: @representative.id,
      news_item:         { representative_id: @representative.id, issue: 'Climate Change' }
    }
  end

  def selected_article_params
    {
      representative_id: @representative.id,
      selected_article:  '0',
      news_item:         { representative_id: @representative.id, issue: 'Climate Change' },
      articles:          { '0' => @article }
    }
  end

  def stub_currents_response(news: [@article])
    allow(ENV).to receive(:fetch).with('CURRENTS_API_KEY', anything).and_return('test-key')
    body = { 'status' => 'ok', 'news' => news }.to_json
    response = instance_double(Faraday::Response, success?: true, status: 200, body: body)
    allow(Faraday).to receive(:get).and_return(response)
  end

  describe 'GET new' do
    it 'builds a news item for the current representative' do
      get :new, params: { representative_id: @representative.id }

      expect(assigns(:news_item).representative).to eq(@representative)
    end
  end

  describe 'GET search' do
    it 'loads Currents articles for the selected issue' do
      stub_currents_response

      get :search, params: search_params

      expect(assigns(:articles)).to eq([@article])
    end

    it 'renders the search form when required inputs are missing' do
      get :search, params: { representative_id: @representative.id, news_item: { issue: '' } }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'POST create' do
    it 'creates a news item from the selected Currents article' do
      expect { post :create, params: selected_article_params }
        .to change(NewsItem, :count).by(1)
      expect(NewsItem.last.title).to eq('Climate Story')
    end

    it 'stores the selected issue and current user' do
      post :create, params: selected_article_params

      expect(NewsItem.last.issue).to eq('Climate Change')
      expect(NewsItem.last.user).to eq(@user)
    end
  end
end
