Feature: Add issues column to news articles

As a political activist or voter,
So that I can inform other voters with news of other political candidates,
I want to add an issues column to news articles for each candidate.

Scenario: Create a news article for a candidate
  Given there is a representative with a news article
  And I am on the news articles page for that representative
  Then I should see "Issue"
  And I should see "Climate Change"
