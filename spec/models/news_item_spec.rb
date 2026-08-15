# frozen_string_literal: true

# == Schema Information
#
# Table name: news_items
#
#  id                :integer          not null, primary key
#  average_rating    :decimal(3, 2)   default(0.0), not null
#  description       :text
#  issue             :string
#  link              :string           not null
#  title             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  representative_id :integer          not null
#  user_id           :integer
#
# Indexes
#
#  index_news_items_on_representative_id  (representative_id)
#  index_news_items_on_user_id            (user_id)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe NewsItem do
  describe '.find_for' do
    before do
      @user = User.create!(uid: 'placeholder', provider: :developer)
      @representative = Representative.create!(name: 'Jane Doe', title: 'Representative', ocdid: 'rep-1')
      @other_representative = Representative.create!(name: 'John Doe', title: 'Senator', ocdid: 'rep-2')
      @news_item = described_class.create!(
        representative: @representative,
        title:          'Town Hall',
        link:           'https://example.com/town-hall',
        description:    'Local coverage',
        user: @user
      )
      described_class.create!(
        representative: @other_representative,
        user: @user,
        title:          'Other Story',
        link:           'https://example.com/other'
      )
    end

    it 'returns a news item for the requested representative' do
      expect(described_class.find_for(@representative.id)).to eq(@news_item)
    end

    it 'returns nil when the representative has no news item' do
      new_representative = Representative.create!(name: 'No News', title: 'Mayor', ocdid: 'rep-3')

      expect(described_class.find_for(new_representative.id)).to be_nil
    end
  end

  describe '.issues' do
    it 'returns the correct issues array' do
      expect(described_class.issues).to include(
        'Terrorism', 'Social Security and Medicare', 'Abortion',
        'Student Loans', 'Free Speech'
      )

      expect(described_class.issues.length).to eq(17)
    end
  end

  describe '#average_rating_display' do
    it 'shows unrated articles clearly' do
      user = User.create!(uid: 'rating-user', provider: :developer)
      representative = Representative.create!(name: 'Jane Doe', title: 'Representative', ocdid: 'rating-rep')
      news_item = described_class.create!(
        representative: representative,
        user:           user,
        title:          'Story',
        link:           'https://x.test'
      )

      expect(news_item.average_rating_display).to eq('Not rated')
    end
  end
end
