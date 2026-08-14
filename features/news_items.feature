Feature: Add issues column to news articles

As a political activist or voter,
So that I can inform other voters with news of other political candidates,
I want to add an issues column to news articles for each candidate.

Scenario: Create a news article for a candidate
  Given I am on the home page
  And I click 
  And I visit the representative search for "Sonoma County"
  Then I should see "Jared Huffman"