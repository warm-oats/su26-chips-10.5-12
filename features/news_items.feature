Feature: Add issues column to news articles

As a political activist or voter,
So that I can inform other voters with news of other political candidates,
I want to add an issues column to news articles for each candidate.

Scenario: Create a news article for a candidate
  Given I am on the login page
  And Currents has articles for "Free Speech"
  When I log in with Google
  Then I am on the homepage
  And I should see "Profile"
  Then I click "Profile"
  Then I should see "Your Profile"
  And I should see "google_test@example.com"
  And I should see "Google Test Developer"
  And I should see "Logout"
  And I visit the representative search for "Sonoma County"
  Then I should see "Jared Huffman"
  Then I click "News Articles"
  And I click "Add News Article"
  Then I should see "Find news articles"
  And I select "Jared Huffman" from "Representative"
  And I select "Free Speech" from "Issue"
  And I press "Search"
  Then I should see "Select news article"
  And I should see "Free Speech Article"
  And I should see "https://example.com/free-speech"
  And I press "Save"
  Then I should see "News item was successfully created."
  And I should see "Free Speech Article"
  And I should see "https://example.com/free-speech"
  And I should see "Free speech coverage"
  And I should see "Jared Huffman"
