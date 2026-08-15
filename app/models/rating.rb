# frozen_string_literal: true

class Rating < ApplicationRecord
  belongs_to :news_item
  belongs_to :user

  validates :score, numericality: {
    only_integer:             true,
    greater_than_or_equal_to: 1,
    less_than_or_equal_to:    5
  }
  validates :user_id, uniqueness: { scope: :news_item_id }

  after_save :refresh_news_item_average_rating
  after_destroy :refresh_news_item_average_rating

  private

  def refresh_news_item_average_rating
    news_item.update_average_rating!
  end
end
