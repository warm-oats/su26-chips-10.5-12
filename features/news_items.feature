Feature: Add issues column to news articles

As a political activist or voter,
So that I can inform other voters with news of other political candidates,
I want to add an issues column to news articles for each candidate.

Scenario: Create a news article for a candidate
  Given I am on the login page
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
  Then I should see "New news article"
  And I fill in "Title" with "Title"
  And I fill in "Link" with "Link.com"
  And I fill in "Description" with "Description"
  And I select "Jared Huffman" from "Representative"
  And I select "Free Speech" from "Issue"
  And I press "Save"
  Then I should see "News item was successfully created."
  And I should see "Title"
  And I should see "Link.com"
  And I should see "Description"
  And I should see "Jared Huffman"
