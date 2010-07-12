@cas2.0
Feature: /proxy

  Scenario: /proxy
    Given I have a proxy granting ticket for proxy "https://test-proxy.com/"
    When I request a proxy ticket for "http://test.com/"
    Then I should have xpath "//cas:proxySuccess"
    And I should have xpath "//cas:proxyTicket" with text "PT-"

  Scenario: /proxy with invalid proxy granting ticket
    Given an invalid proxy granting ticket
    When I request a proxy ticket for "http://test.com/"
    Then I should have xpath "//cas:proxyFailure[@code='BAD_PGT']"
