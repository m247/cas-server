@cas1.0
Feature: /validate
  In order to allow a client into an application
  As an authentication client
  I want to verify a service ticket

  Scenario: /validate with valid ticket
    Given I have a valid service ticket for "http://test.com/"
    When I validate the service ticket for "http://test.com/"
    Then I should see "yes"
    And I should see "testing"
    And I should not see "no"

  Scenario: /validate without valid ticket
    Given an invalid service ticket
    When I validate the service ticket for "http://test.com/"
    Then I should see "no"
    And I should not see "yes"

  Scenario: /validate?renew=true credential granted service
    Given I have a valid service ticket for "http://test.com/"
    When I validate the service ticket for "http://test.com/" with the renew option
    Then I should see "yes"
    And I should see "testing"
    And I should not see "no"

  Scenario: /validate?renew=true cookie granted service
    Given I have a valid service ticket for "http://test.com/"
    And the service ticket was granted by a cookie
    When I validate the service ticket for "http://test.com/" with the renew option
    Then I should see "no"
    And I should not see "yes"
