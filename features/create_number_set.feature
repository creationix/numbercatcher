Feature: Create new number set
  In order to set more critical numbers
  As a administrator
  I want to create a new number set
  
  Scenario: New number set has not existed
    Given I'm an authenticated administrator
  	And I am on Listing of Number Sets page
  	And new number set 'name' has not existed 
  	And I fill in 'name' for 'new name'
  	And I choose 'Integer'
  	When I press 'Create'    
    Then I should see a new number set named 'name' on the list of number sets

  Scenario: New number set has already existed
    Given I'm an authenticated administrator 
  	And I am on Listing of Number Sets page
  	And new number set 'name' has already existed 
  	And I fill in 'name' for 'new name'
  	And I choose 'Integer'
  	When I press 'Create'    
    Then I should see an error saying that 'The number set has already existed' 
  