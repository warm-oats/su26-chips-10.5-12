# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NewsItemsController do
  before do
    @user = User.create!(uid: 'user-1', provider: :github)
    @representative = Representative.create!(name: 'Jane Doe', title: 'Representative', ocdid: 'rep-1')
    @news_item = NewsItem.create!(
      representative: @representative,
      title:          'Town Hall',
      link:           'https://example.com/town-hall',
      description:    'Local coverage'
    )
  end

  describe 'GET index' do
    it 'loads news items for the representative' do
      get :index, params: { representative_id: @representative.id }

      expect(assigns(:news_items)).to contain_exactly(@news_item)
    end

    it 'tracks the current user id when logged in' do
      session[:user_id] = @user.id

      get :index, params: { representative_id: @representative.id }

      expect(assigns(:curr_user_id)).to eq(@user.id)
    end
  end

  describe 'GET show' do
    it 'loads the requested news item' do
      get :show, params: { representative_id: @representative.id, id: @news_item.id }

      expect(assigns(:news_item)).to eq(@news_item)
    end
  end
end
