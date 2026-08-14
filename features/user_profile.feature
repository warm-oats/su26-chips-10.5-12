Feature: User can login and shows user information
  As a visitor
  So that I can access and use my account
  I want to login and see my user profile information

Scenario: User successful login shows user information
  Given I am on the login page
  When I log in with Google
  Then I am on the homepage
  And I should see "Profile"
  Then I click "Profile"
  Then I should see "Your Profile"
  And I should see "google_test@example.com"
  And I should see "Google Test Developer"
  And I should see "Logout"

  