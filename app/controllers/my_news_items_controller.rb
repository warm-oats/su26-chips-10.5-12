# frozen_string_literal: true

class MyNewsItemsController < ApplicationController
  before_action :require_login!

  before_action :set_representative
  before_action :set_representatives_list
  before_action :set_news_item, only: %i[edit update destroy]

  def new
    @news_item = NewsItem.new(representative: @representative)
  end

  def edit; end

  def search
    @news_item = NewsItem.new(search_news_item_params)
    return render_missing_search_params unless search_params_present?

    @representative = Representative.find(@news_item.representative_id)
    @articles = CurrentsNewsClient.new.search(@news_item.issue)
  rescue CurrentsNewsClient::Error, ArgumentError => e
    render_failed_search(e.message)
  end

  def create
    @news_item = NewsItem.new(news_item_attributes)
    @news_item.user = current_user
    @representative = @news_item.representative || @representative

    if save_news_item_with_optional_rating
      redirect_to representative_news_item_path(@representative, @news_item),
                  notice: 'News item was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @news_item.update(news_item_params)
      redirect_to representative_news_item_path(@representative, @news_item),
                  notice: 'News item was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @news_item.destroy
    redirect_to representative_news_items_path(@representative),
                notice: 'News was successfully destroyed.'
  end

  private

  def set_representative
    @representative = Representative.find(
      params[:representative_id]
    )
  end

  def set_representatives_list
    @representatives_list = Representative.all.map { |r| [r.name, r.id] }
  end

  def set_news_item
    @news_item = NewsItem.find(params[:id])
  end

  def news_item_params
    params.require(:news_item).permit(:title, :issue, :description, :link, :representative_id)
  end

  def search_news_item_params
    params.require(:news_item).permit(:representative_id, :issue)
  end

  def news_item_attributes
    return news_item_params if params[:selected_article].blank?

    selected_article_attributes.merge(search_news_item_params.to_h)
  end

  def selected_article_attributes
    article = params.require(:articles).require(params[:selected_article]).permit(:title, :url, :description)
    { title: article[:title], link: article[:url], description: article[:description] }
  end

  def save_news_item_with_optional_rating
    ActiveRecord::Base.transaction do
      @news_item.save!
      create_rating! if rating_score.present?
    end
    true
  rescue ActiveRecord::RecordInvalid => e
    add_rating_error(e.record) unless e.record == @news_item
    false
  end

  def create_rating!
    @news_item.ratings.create!(user: current_user, score: rating_score)
  end

  def rating_score
    params[:rating_score]
  end

  def add_rating_error(rating)
    @news_item.errors.add(:base, rating.errors.full_messages.to_sentence)
  end

  def search_params_present?
    @news_item.representative_id.present? && @news_item.issue.present?
  end

  def render_missing_search_params
    render_failed_search('Select a representative and issue before searching.')
  end

  def render_failed_search(message)
    flash.now[:alert] = message
    render :new, status: :unprocessable_entity
  end
end
