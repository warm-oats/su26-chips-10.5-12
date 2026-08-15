# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rating do
  before do
    @representative = Representative.create!(name: 'Jane Doe', title: 'Representative', ocdid: 'rep-1')
    @user = User.create!(uid: 'user-1', provider: :github)
    @other_user = User.create!(uid: 'user-2', provider: :github)
    @news_item = NewsItem.create!(
      representative: @representative,
      user:           @user,
      title:          'Climate Story',
      link:           'https://example.com/climate-story'
    )
  end

  it 'updates the news item average rating when ratings are created' do
    described_class.create!(news_item: @news_item, user: @user, score: 5)
    described_class.create!(news_item: @news_item, user: @other_user, score: 3)

    expect(@news_item.reload.average_rating).to eq(4.0)
  end

  it 'requires scores from 1 through 5' do
    rating = described_class.new(news_item: @news_item, user: @user, score: 6)

    expect(rating).not_to be_valid
  end

  it 'allows one rating per user for a news item' do
    described_class.create!(news_item: @news_item, user: @user, score: 4)

    duplicate = described_class.new(news_item: @news_item, user: @user, score: 5)

    expect(duplicate).not_to be_valid
  end
end
