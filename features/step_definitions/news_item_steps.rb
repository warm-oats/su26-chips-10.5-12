# frozen_string_literal: true

Given 'there is a representative with a news article' do
  @news_item_representative = Representative.find_or_create_by!(ocdid: 'a11y-rep') do |representative|
    representative.name = 'Jane Doe'
    representative.title = 'Representative'
  end

  user = User.find_or_create_by!(uid: 'a11y-user', provider: :github) do |created_user|
    created_user.first_name = 'A11y'
    created_user.last_name = 'User'
    created_user.email = 'a11y@example.com'
  end

  @news_item = NewsItem.find_or_create_by!(
    representative: @news_item_representative,
    title:          'Climate Story',
    link:           'https://example.com/climate-story'
  ) do |news_item|
    news_item.user = user
    news_item.issue = 'Climate Change'
    news_item.description = 'Local reporting about climate policy.'
  end
end

Given 'I am on the news articles page for that representative' do
  visit representative_news_items_path(@news_item_representative)
end

Given 'I am on the news article page for that article' do
  visit representative_news_item_path(@news_item_representative, @news_item)
end
