Feature: ActionMap Shows State and County Maps

Scenario: Navigating States and counties
  Given I am on the homepage
  Then I should see "National Map"
  When I click the state "CA"
  Then I should see "California"
  And I should be on the state page for "CA"

@javascript
Scenario: County map exposes representative search targets
  Given I am on the homepage
  When I click the state "CA"
  Then I should see 58 counties
  And I should see the county "Alameda County"
  And the county "Alameda County" should search representatives for "Alameda County, CA"

Scenario: County search renders representative results
  Given the Geocodio lookup for "Alameda County, CA" returns representatives
  When I visit the representative search for "Alameda County, CA"
  Then I should see "Search Results"
  And I should see "Jane County"
  And I should see "Representative"
