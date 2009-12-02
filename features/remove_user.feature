Feature: Delete a user
  In order to get rid of account that is no longer used
  As a administrator
  I want to delete a user
  
  Scenario: Delete a normal or standard user
    Given I have logged in as a administrator
  	And I am on User Administration page	
  	When I press 'Delete'    
    Then I should see the user disappear on system users list
