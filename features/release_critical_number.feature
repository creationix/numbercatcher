Feature: Release a critical number
  In order to get rid of a no longer needed critical number
  As a user
  I want to release that critical number

  Scenario: User releases a critical number 
    Given I'm an authenticated user
  	And I visit the User Profile page	
  	When I press 'Release'   
    Then I should see that number disappears on my reserved numbers table
  