[![Build Status](https://travis-ci.com/raldi87/brocadeapi_client.svg?token=mkJwysQXyF3sdXnco1UE&branch=master)](https://travis-ci.com/raldi87/brocadeapi_client)

Brocade API Client for SAN tasks Automation
====================
This is a Client library that can talk to the Brocade Network Advisor API. The BNA 
has a REST web service interface which can be queried.
This library implements an interface for talking to the Brocade Advisor and help SAN Admins automate SAN tasks.

Prerequsites
============
* Brocade Network Advisor
  * 14.2.0 
  * 14.4.0 for Peer Zoning Support
* Ruby - 2.4.x or higher.
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
gem 'brocadeapi_client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install brocadeapi_client

## Usage
=============
```ruby
 #Create an instance of brocadeapi_client::Client
 client = BrocadeAPIClient::Client.new('https://BNA_IP/rest')

 #Login using Brocade Network Advisor API credential
 client.login('BNA_user', 'BNA_password')

 #Call any method from client class 
 client.alishow(FABRICKEY,'alitest_port1')

 #Logout once you have finished all of your operations
 client.logout
 
 # For zoning operations (zonecreate/add/remove , alicreate/add/remove and cfgadd/cfgremove) you must start a transaction before sending a request to the Advisor
 # After submitting, you must commit your transactions. 
 # Below you can how to create a zone and peerzone
 # FABRICKEY is the seed switch WWN from the fabric on which you want to make the changes. Using the fabrics and fabric method you can obtain it easily. Keep in mind this WWN might change, so you might want to use the methods first tobtain de fabric WWN
 client.trans_start(FABRICKEY)
 client.alicreate(FABRICKEY, 'test_alias', '10:00:00:10:9b:52:a8:0b')
 client.zonecreate_standard(FABRICKEY, 'test_zone', 'test_alias')
 client.cfgadd(FABRICKEY,'test_config','test_zone')
 client.trans_commit(FABRICKEY)

 # For Peerzoning:
 client.zonecreate_peerzone(FABRICKEY, 'test_zone', principal: [ WWN ARRAY ], members: [WWN ARRAY])
 
Unit Tests
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
2. Create a named feature branch (like `feature_x`)
3. Write your change
4. Write tests for your change 
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

## License

This project is licensed under the Apache 2.0 license.

