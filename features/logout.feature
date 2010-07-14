Feature: /logout
  In order to end my session
  As a logged in client
  I want to logout of the session

  Scenario: /logout
    Given I have a single sign on session
    When I visit "/logout"
    Then I should see "You have logged out"

  Scenario: /logout with url
    Given I have a single sign on session
    When I visit "/logout?url=http://test.com/"
    Then I should see "You have logged out"
    And I should see "http://test.com/"
