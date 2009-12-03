Feature: Delete a number set
  In order to get rid of a number set that is no longer used
  As a administrator
  I want to delete a number set
  
  Scenario: Delete a normal or standard user
    Given I'm an authenticated administrator
  	And I visit the Listing of Number page	
  	When I press 'Delete'    
    Then I should see the number set disappear on critical number set list
