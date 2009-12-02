Feature: Create a new user
  In order to help a user create a new account
  As a administrator
  I want to create a new user
  
  Scenario: New user has not existed
    Given I'm an authenticated administrator
    And I visit the users page
    And I fill in 'Terry' for 'New Username'
    And I fill in 'Quyen' for 'New Real Name'
    And I select 'Normal User' for 'Type of user'
    When I press 'Add New User'    
    Then I should see 'Terry\s+Quyen\s+Normal User'

  Scenario: New user has already existed
    Given I'm an authenticated administrator
    And I visit the users page
    And a user exists with username 'Terry' and password 'password'
    And I fill in 'Terry' for 'New Username'
    And I fill in 'Quyen' for 'New Real Name'
    And I select 'Normal User' for 'Type of user'
    When I press 'Add New User'    
    Then I should see an error saying 'Problem in creating new user: Username is already taken'
  