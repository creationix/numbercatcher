Feature: Remove a range of number from pool 
  In order to get rid of no longer needed numbers
  As a administrator
  I want to remove some numbers from the pool
  
  Scenario: No number reserved in range
    Given I have logged in as a administrator
  	And I am on Number Set Details page
  	And 'from' number belongs to the pool 
  	And 'to' number belongs to the pool
  	And no reserved numbers in between 'from' and 'to'
  	And I fill in 'from' for 'from'
  	And I fill in 'to' for 'to'
  	When I press 'Remove From pool'    
    Then I should see a notice that 'Requested range has been removed from pool'

  Scenario: Some reserved numbers in range
    Given I have logged in as a administrator
  	And I am on Number Set Details page
  	And 'from' number belongs to the pool 
  	And 'to' number belongs to the pool
  	And some reserved numbers in between 'from' and 'to'
  	And I fill in 'from' for 'from'
  	And I fill in 'to' for 'to'
  	When I press 'Remove From pool'    
    Then I should see a notice that 'There are reserved number in requested range'
	
  Scenario: Range is not in pool
    Given I have logged in as a administrator
  	And I am on Number Set Details page
  	And 'from' number does not belong to the pool 
  	And 'to' number does not belong to the pool	
  	And I fill in 'from' for 'from'
  	And I fill in 'to' for 'to'
  	When I press 'Remove From pool'    
    Then I should see a notice that 'Requested range does not belong to pool'
  