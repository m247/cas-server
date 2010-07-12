Feature: /login as credential acceptor
  As a login client
  In order to authenticate to an application
  I want to provide my login credentials

  Background:
    Given a user with credentials "testing" and password "testing"
  
  Scenario: /login without service
    When I visit "/login"
    And I fill in the following:
      | username | testing |
      | password | testing |
    And I press "Sign In"
    Then I should see "You are logged in"

  Scenario: /login with service
    When I visit "/login?service=http://test.com/redirection"
    When I fill in the following:
      | username | testing |
      | password | testing |
    And I press "Sign In"
    Then I should be redirected to "http://test.com/redirection"

  Scenario: /login with service and warn
    When I visit "/login?service=http://test.com/redirection&warn=true"
    And I fill in the following:
      | username | testing |
      | password | testing |
    And I press "Sign In"
    Then I should see "Successfully Signed In"
    And I should see "Redirecting you to http://test.com/redirection shortly"
