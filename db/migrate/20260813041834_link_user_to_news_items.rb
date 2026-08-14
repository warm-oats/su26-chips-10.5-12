# frozen_string_literal: true

class LinkUserToNewsItems < ActiveRecord::Migration[7.2]
  def change
    add_reference :news_items, :user, foreign_key: true
  end
end
