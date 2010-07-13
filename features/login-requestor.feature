Feature: /login as credential requestor
  In order to provide login credentials
  As a login client
  I want to see a login form

  Scenario: /login without a session
    When I visit "/login"
    Then I should see fields:
      | username |
      | password |
      | lt       |

  Scenario: /login with a session
    Given I have a single sign on session
    When I visit "/login"
    Then I should see "You are logged in"

  Scenario: /login?service=http://test.com/redirection without a session
    When I visit "/login?service=http://test.com/redirection"
    Then I should see fields with values:
      | username |                             |
      | password |                  					 |
      | service  | http://test.com/redirection |
      | lt       |                             |

  Scenario: /login?service=http://test.com/ with a session
    Given I have a single sign on session
    When I visit "/login?service=http://test.com/redirection"
    Then I should see "You are logged in"

  Scenario: /login?gateway=true&service=http://test.com/redirection without a session
    When I visit "/login?gateway=true&service=http://test.com/redirection"
    Then I should be redirected to "http://test.com/redirection" without a service ticket

  Scenario: /login?gateway=true&service=http://test.com/redirection with a session
    Given I have a single sign on session
    When I visit "/login?gateway=true&service=http://test.com/redirection"
    Then I should be redirected to "http://test.com/redirection" with a service ticket

  Scenario: /login?renew=true&service=http://test.com/redirection with a session
    Given I have a single sign on session
    When I visit "/login?renew=true&service=http://test.com/redirection"
    Then I should see fields:
      | username |
      | password |
      | lt       |
