Feature: Add range for a number set
  In order to have a number set with upper and lower bound
  As a administrator
  I want to add range for that number set
  
  Scenario: New range does not overlap existing ranges
    Given I'm an authenticated administrator
    And I visit the Number Set Details page
    And 'from' number does not belong to any existing range 
    And 'to' number does not belong to any existing range 
    And I fill in 'from' for 'from'
    And I fill in 'to' for 'to'
    When I press 'Make Available'    
    Then I should see a new range of number on the list

  Scenario: New range overlaps existing ranges
    Given I'm an authenticated administrator
    And I visit the Number Set Details page
    And 'from' number belongs to any existing range 
    And 'to' number does not belong to any existing range 
    And I fill in 'from' for 'from'
    And I fill in 'to' for 'to'
    When I press 'Make Available'    
    Then I should see a prompt asking 'ok' for adding non duplicated numbers and 'cancel' otherwise
  