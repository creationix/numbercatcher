Feature: Request a critical number
  In order to reserve a critical number
  As a user
  I want to make a request for that critical number

  Scenario: Critical number is available
    Given I have logged in as a user
  	And I am on Number Set Details page
  	And a critical 'number' is available
  	And I fill in 'number' for 'number'
  	When I press 'Reserve'    
    Then I should see a notice saying 'Number is reserved successfully'
  	And a new critical number appears on number list

  Scenario: Critical number is not available
    Given I have logged in as a user
  	And I am on Number Set Details page
  	And a critical 'number' is not available
  	And I fill in 'number' for 'number'
  	When I press 'Reserve'    
    Then I should see an error saying 'Number is not available'
	
  
  
  