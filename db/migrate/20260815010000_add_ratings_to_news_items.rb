# frozen_string_literal: true

class AddRatingsToNewsItems < ActiveRecord::Migration[7.2]
  def change
    add_column :news_items, :average_rating, :decimal, precision: 3, scale: 2, default: 0.0, null: false

    create_table :ratings do |t|
      t.references :news_item, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :score, null: false

      t.timestamps
    end

    add_index :ratings, %i[news_item_id user_id], unique: true
  end
end
