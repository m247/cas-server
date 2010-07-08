@cas2.0
Feature: /serviceValidate
  In order to allow a client into an application
  As an authentication client
  I want to verify a service ticket

  Scenario: /serviceValidate with valid ticket
    Given I have a valid service ticket for "http://test.com/"
    When I serviceValidate the service ticket for "http://test.com/"
    Then I should have xpath "//cas:authenticationSuccess"
    And I should have xpath "//cas:user" with text "testing"
    And I should not have xpath "//cas:proxyGrantingTicket"

  Scenario: /serviceValidate with invalid ticket
    Given an invalid service ticket
    When I serviceValidate the service ticket for "http://test.com/"
    Then I should have xpath "//cas:authenticationFailure[@code='INVALID_TICKET']"

  Scenario: /serviceValidate with valid ticket but invalid service
    Given I have a valid service ticket for "http://test.com/"
    When I serviceValidate the service ticket for "http://test.net/"
    Then I should have xpath "//cas:authenticationFailure[@code='INVALID_SERVICE']"

  Scenario: /serviceValidate with proxy callback
    Given I have a valid service ticket for "http://test.com/"
    When I serviceValidate the service ticket for "http://test.com/" with proxy URL "https://test-proxy.com/"
    Then I should have xpath "//cas:authenticationSuccess"
    And I should have xpath "//cas:proxyGrantingTicket" with text "PGTIOU-"

  Scenario: /serviceValidate with invalid proxy callback
    Given I have a valid service ticket for "http://test.com/"
    When I serviceValidate the service ticket for "http://test.com/" with proxy URL "http://test-proxy.com/"
    Then I should have xpath "//cas:authenticationSuccess"
    And I should not have xpath "//cas:proxyGrantingTicket"
