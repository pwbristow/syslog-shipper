@aruba @announce
Feature: Sends log data
  Scenario: When I connect to a valid host
    Given I have a valid endpoint
    When I connect to that endpoint
    Then the connection should succeed
  
  Scenario: When I securely connect to a valid host
    Given I have a valid TLS endpoint
    When I securely connect to that endpoint
    Then the connection should succeed

  Scenario Outline: When I connect to an invalid host
    Given I have an invalid TLS endpoint
    When I connect to the insecure endpoint
    And I am prompted to accept the certificate
    And I type "<answer>"
    Then the output should contain "<outcome>"

  Scenarios:
    | answer | outcome              |
    | yes    | verified peer        |
    | no     | Couldn't verify peer |

  Scenario: Bypassing peer checking via the command line
    Given I have an invalid TLS endpoint
    When I connect to that endpoint with and bypass peer checking
    Then I am not prompted to accept the certificate
    And the connection should succeed
