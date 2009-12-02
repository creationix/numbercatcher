Feature: User authentication
  In order to restrict access to the system
  As a user
  I want to gain access only when I enter proper credentials

  Scenario: User logs in
    Given I visit the login page
    And a user exists with username 'admin' and password 'password'
    And I fill in 'admin' for 'username'
    And I fill in 'password' for 'password'
    When I press 'Login'
    Then I should be on the home page
    And I should see a notice saying 'Login successful'

  Scenario: User enters wrong credentials
    Given I visit the login page
    And a user exists with username 'admin' and password 'password'
    And I fill in 'admin' for 'username'
    And I fill in 'wrong_password' for 'password'
    When I press 'Login'
    Then I should be on the login page
    And I should see an error saying 'Incorrect credentials.  Please try again'

  Scenario: Authenticated user visits login page
    Given I'm an authenticated user
    When I visit the login page
    Then I should be on the home page

  Scenario: Unauthenticated user visits internal page
    Given I'm not an authenticated user
    When I visit the home page
    Then I should be on the login page
    And I should see an error saying 'Please login first.'

  Scenario: Unauthenticated user visits help page
    Given I'm not an authenticated user
    When I visit the help page
    Then I should be on the help page

  Scenario: User logs out
    Given I'm an authenticated user
    When I visit the logout page
    Then I should be on the login page
    And I should see a notice saying 'You have logged out successfully.'
