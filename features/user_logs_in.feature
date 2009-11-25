Feature: User authentication
  In order enter the system
  As a user
  I want to gain access only when I enter proper credentials
  
  Scenario: User logs in
    Given I visit the login page
    And I fill in 'admin' for 'username'
    And I fill in 'password' for 'password'
    When I press 'Login'
    Then I should be on the home page
    And I should see 'Login successful'
  
  Scenario: User enters wrong credentials
    Given I visit the login page
    And I fill in 'admin' for 'username'
    And I fill in 'wrong_password' for 'password'
    When I press 'Login'
    Then I should be on the login page
    And I should see 'Incorrect credentials.  Please try again'
  
  
  

  
