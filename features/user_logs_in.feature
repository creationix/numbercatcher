Feature: User authentication
  In order to log in
  As a user
  I want a login form to enter my credentials into
  
  Scenario: user goes to login page
    Given a connection to the app
    And I have an empty session
    When I request the url /
    Then the page should contain a login form
  
  Scenario: user enters 
  
  
  

  
