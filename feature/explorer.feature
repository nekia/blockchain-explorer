# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#


Feature: Bootstrapping Hyperledger Fabric
    As a user I want to be able to bootstrap my fabric network

@daily
@doNotDecompose
Scenario: test scenario
    Given I have a bootstrapped fabric network of type solo without tls
    When an admin sets up a channel named "mychannel"
    And I start explorer
    Then the logs on explorer.mynetwork.com contains "Synchronizer pid is " within 10 seconds

    Given a request url http://localhost:8090/auth/networklist
    When  the request sends GET
    Then the response status is 200
    And the response json matches
        """
        {
            "type": "object",
            "properties": {
                "networkList": { "type": "array" }
            },
            "required": ["networkList"]
        }
        """
    And the response json at $.networkList is equal to [["first-network", {}]]

    # Given a request url 'http://localhost:8090/auth/login?user=test&password=test&network={0}'.format($.networkList[0][0])
    # When  the request sends GET
    # Then the response status is 200
    
