@cas2.0
Feature: /proxyValidate

  Scenario: /proxyValidate with valid ticket
    Given I have a valid proxy ticket for "http://test.com/" with proxy "https://test-proxy.com/"
    When I proxyValidate the proxy ticket for "http://test.com/"
    Then I should have xpath "//cas:authenticationSuccess"
    And I should have xpath "//cas:user" with text "testing"
    And I should have xpath "//cas:proxy" with text "https://test-proxy.com/"

  Scenario: /proxyValidate with invalid ticket
    Given an invalid proxy ticket
    When I proxyValidate the proxy ticket for "http://test.com/"
    Then I should have xpath "//cas:authenticationFailure[@code='INVALID_TICKET']"

  Scenario: /proxyValidate with valid ticket but invalid proxy
    Given I have a valid proxy ticket for "http://test.com/" with proxy "https://test-proxy.com/"
    When I proxyValidate the proxy ticket for "http://test.net/"
    Then I should have xpath "//cas:authenticationFailure[@code='INVALID_SERVICE']"
