Feature: Create a new user
  In order to help a user create a new account
  As a administrator
  I want to create a new user
  
  Scenario: New user has not existed
    Given I have logged in as a administrator
    And I am on User Administration page
    And a user with username 'Terry' and realname 'Quyen' does not exist 
    And I fill in 'Terry' for 'username'
    And I fill in 'Quyen' for 'realname'
    And I choose 'Normal User' for 'usertype'
    When I press 'Add New User'    
    Then I should see a new user appear on syste user list

  Scenario: New user has already existed
    Given I have logged in as a administrator
    And I am on User Administration page
    And a user exists with username 'Terry' and realname 'Quyen'  
    And I fill in 'Terry' for 'username'
    And I fill in 'Quyen' for 'realname'
    And I choose 'Normal User' for 'usertype'
    When I press 'Add New User'    
    Then I should see an error saying that 'User has already existed'
  