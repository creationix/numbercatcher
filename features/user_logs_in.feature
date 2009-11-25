Feature: User authentication
  In order to log in
  As a user
  I want a login form to enter my credentials into
  
  Scenario: User logs in
    Given I visit the login page
    And I fill in 'admin' for 'username'
    And I fill in 'password' for 'password'
    When I press 'Login'
    Then I should be on the home page
    And I should see 'Welcome admin'
  
  Scenario: User enters wrong credentials
    Given I visit the login page
    And I fill in 'admin' for 'username'
    And I fill in 'wrong_password' for 'password'
    When I press 'Login'
    Then I should be on the login page
    And I should see 'Incorrect credentials.  Please try again.'
  
  
  

  
