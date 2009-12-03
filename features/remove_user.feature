Feature: Delete a user
  In order to get rid of account that is no longer used
  As a administrator
  I want to delete a user
  
  Scenario: Delete a normal or standard user
    Given I'm an authenticated administrator
  	And I visit the User Administration page	
  	When I press 'Delete'    
    Then I should see the user disappear on system users list
