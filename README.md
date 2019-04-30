[![Build Status](https://travis-ci.com/raldi87/brocadeapi_client.svg?token=mkJwysQXyF3sdXnco1UE&branch=master)](https://travis-ci.com/raldi87/brocadeapi_client)

Brocade Network Advisor API Client for SAN tasks Automation
====================
This is a Client library that can talk to the Brocade Network Advisor API. The BNA 
has a REST web service interface which can be queried.
This library implements an interface for talking to the Brocade Advisor and help SAN Admins automate SAN tasks.

Prerequsites
============
* Brocade Network Advisor
  * 14.2.0 
  * 14.4.0 for Peer Zoning Support
* Ruby - 2.2.x or higher.
* Brocade Network Advisor REST API Service must be enabled on the Server.
* Different vendors have there own flavor of Brocade Network Advisor which they are named accordingly: HPE Network Advisor, IBM Network Advisor. All are compatible as they are all based on Brocade Network Advisor.

Features
============

    * resourcegroups
    * fabrics
    * fabric
    * fabricswitches
    * allswitches
    * allports
    * change_portstates
    * change_persistentportstates
    * set_portname
    * zoneshow_all
    * zoneshow_all_active
    * zoneshow_all_defined
    * zoneshow_active
    * zoneshow_defined
    * zonecreate_standard
    * zonecreate_peerzone
    * zonedelete
    * zoneadd_standard
    * zoneremove_standard
    * zoneadd_peerzone
    * zoneremove_peerzone
    * zonedbs
    * alishow
    * cfgshow
    * cfgadd
    * cfgremove
    * cfgenable
    * alicreate
    * aliadd
    * aliremove
    * alidelete
    * trans_start
    * trans_commit
    * trans_abort
    * syslog_events
    * trap_events
    * custom_events

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'brocade_api_client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install brocade_api_client

## Usage
=============
```ruby
 #Create an instance of brocadeapi_client::Client
 client = BrocadeAPIClient::Client.new('https://BNA_IP/rest')
 # The Client supports logging and debug mode . Log format is :logstash
 client = BrocadeAPIClient::Client.new('https://BNA_IP/rest', enable_logger: true, log_file_path: 'test.log'
 # Also debug mode is supported by the debug parameters on the Client class constructor. By default its set to false.

 #Login using Brocade Network Advisor API credential
 client.login('BNA_user', 'BNA_password')

 #Call any method from client class 
 client.alishow(FABRICKEY,'alitest_port1')

 #Logout once you have finished all of your operations
 client.logout
 
 # For zoning operations (zonecreate/add/remove , alicreate/add/remove and cfgadd/cfgremove) 
 # you must start a transaction before sending a request to the Advisor
 # After submitting, you must commit your transactions. 
 # Below you can how to create a zone and peerzone
 # FabricWWN is the seed switch WWN from the fabric on which you want to make the changes. 
 # Using the fabrics and fabric method you can obtain it easily. Keep in mind this WWN might change, 
 # so you might want to use the methods first tobtain de fabric WWN

 client.trans_start('FabricWWN')
 # Alicreate supports unlimited number of arguments as WWN
 client.alicreate('FabricWWN', 'test_alias', '10:00:00:10:9b:52:a8:0b')
 # Zonecreate supports unlimited number of arguments as zonealiases 
 client.zonecreate_standard('FabricWWN', 'test_zone', 'test_alias', 'testalias')
 # cfgadd method supports unlimited number to added as arguments/cfgremove is similar 
 client.cfgadd('FabricWWN','test_config','test_zone')
 client.trans_commit('FabricWWN')
 # To enable the modification 
 client.cfgenable('FabrickWWN')

 # For Peerzoning use:
 # The array support unlimited number of WWN that should be part of the zone
 client.zonecreate_peerzone('FabricWWN', 'test_zone', principal: [ WWN ARRAY ], members: [WWN ARRAY])
 
 # List all fabrics
 client.fabrics
 
 # List fabric description(including seed switch WWN)
 client.fabric('FabricName')

 # List all active zones in a Fabric
 client.zoneshow_all_active('FabricWWN')
 
 # List all defined zones in Fabric
 client.zoneshow_all_defined('FabricWWN')
 
 # List a specific active zones information
 client.zoneshow_active('FabricWWN','zonename')

 # List a specific define zones information
 client.zoneshow_define('FabricWWN','zonename')

 # Show aliases in fabric or for info for a specific alias
 client.alishow('FabricWWN')
 client.alishow('FabricWWN','aliasname')

 # Set port name(PortWWN can be retrieved from allports method)
 client.set_portname('FabricWWN','PortWWN','test_porname')

 # Get all ports
 client.allports

 # Get all switches
 client.allswitches

 # Get all switchs from a specified Fabric
 client.fabricswitches('FabricWWN')

 # Change port state in a switch(non-persistent)
 # Method support unlimited number or portwwns after disale|enable
 client.change_portstates('FabricWWN', 'enable', 'PortWWN1', 'PortWWN2')

 # Change port state in a switch(persistent)
 # Method support unlimited number or portwwns after disale|enable
 client.change_persistentportstates('FabricWWN', 'enable', 'PortWWN1', 'PortWWN2')

 # Delete zones
 # supports unlimited number of zones as arguments 
 client.zonedelete('FabricWWN', 'zone1','zone2')

 # Delete Aliases
 client.alidelete('FabricWWN','alias1','alias2')

 # Create Alias
 client.alicreate('FabricWWN','aliasname','wwn1','wwn2')

 # Add wwn to existing alias
 client.aliadd('FabricWWN','aliasname','wwn1','wwn2')

 # Remove wwns from existing alias 
 client.aliremove('FabricWWN','aliasname','wwn1','wwn2')

 # Zone add/remove (standard)
 # supports unlimited number of arguments as aliases 
 client.zoneremove_standard('10:00:00:27:f8:f7:6b:00', 'test_zone', 'alias1','alias2')
 client.zoneadd_standard('10:00:00:27:f8:f7:6b:00', 'test_zone', 'alias1','alias2')

 # Zone add/remove (peerzone)
 # method supports both principal/members as hash keys or only one of them
 client.zoneadd_peerzone('FabricWWN', 'test_zone', principal: ['wwn1','wwn2'],members: ['wwn1','wwn2'])
 client.zoneremove_peerzone('FabricWWN', 'test_zone', principal: ['wwn1','wwn2'],members: ['wwn1','wwn2'])
 client.zoneadd_peerzone('FabricWWN', 'test_zone', principal: ['wwn1','wwn2'])
 client.zoneremove_peerzone('FabricWWN', 'test_zone', principal: ['wwn1','wwn2'])
 client.zoneadd_peerzone('FabricWWN', 'test_zone', members: ['wwn1','wwn2'])
 client.zoneremove_peerzone('FabricWWN', 'test_zone', members: ['wwn1','wwn2'])

 # List latest syslog evets
 client.syslog_events('999')

 # List latest trap events
 client.trap_events('999')
 
 # List custom events 
 # Below method lists latest 10 events from syslog with warning severity
 client.custom_events('0', '10', 'syslog', 'WARNING')
 
 # Commit changes to fabric defined configuration
 client.trans_commit('FabricWWN')
 
 # Start transaction on defined configuration
 client.trans_start('FabricWWN')
 
 # Abort/Rollback transaction
 client.trans_abort('FabricWWN')

 # Enable defined configuration as an active configuration
 client.cfgenable('FabricWWN') 

 # List zone Databases
 client.zonedbs('FabricWWN')

 # List fabric configuration
 # Defined configuration
 client.cfgshow('FabricWWN','defined')
 # Active configuration
 client.cfgshow('FabricWWN','active')
 # Both active and defined configuration
 client.cfgshow('FabricWWN','all')
``` 
 
## Unit Tests
==========

To run all unit tests:
```bash
 $ rake build:spec
```
The output of the coverage tests will be placed into the ``test_reports`` dir.

To run a specific test:
```bash
 $ rspec spec/client_spec.rb
```

## Contributing
============
1. Fork the repository on Github
2. Write your change
3. Write tests for your change 
4. Run the tests, ensuring they all pass
5. Submit a Pull Request using Github

## License

This project is licensed under the Apache 2.0 license.

