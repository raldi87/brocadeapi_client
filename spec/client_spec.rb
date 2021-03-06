# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.

require 'rspec'
require 'spec_helper'
require 'brocade_api_client'
require 'json'

describe 'BrocadeAPIClient::Client' do
  before(:all) do
    @url = 'http://localhost/rest'
    @user = 'testuser'
    @password = 'password'
  end

  after(:all) do
    @url = nil
  end

  it 'validate_login' do
    session_key = 'logintest'
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    expect(client.http.session_key).to eq(session_key)
  end

  it 'validate_logout' do
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    client.logout
    expect(client.http.session_key).to eq(nil)
  end

  it 'validate_getresources' do
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.resourcegroups
    expect(result.key?('resourceGroups')).to eq(true)
  end

  it 'validate_getfabrics' do
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.fabrics
    expect(result.key?('fcFabrics')).to eq(true)
  end

  it 'validate_getfabrics_withinput' do
    input = '10:00:50:EB:1A:A8:2C:54'
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.fabric(input)
    expect(result['fcFabrics'][0]['key']).to eq(input)
  end

  it 'validate_getallswitches' do
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.allswitches
    expect(result.key?('fcSwitches')).to eq(true)
  end

  it 'validate_getfabricswitches' do
    input = '10:00:00:05:1E:A5:59:B3'
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.fabricswitches(input)
    expect(result.key?('fcSwitches')).to eq(true)
  end

  it 'validate_getallports' do
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.allports
    expect(result.key?('fcPorts')).to eq(true)
  end

  it 'validate_portstate' do
    skey = '10:00:50:EB:1A:A8:2C:54'
    ports = '10:00:00:00:00:00'
    ports2 = '10:00:00:00:00:01'
    state = 'enable'
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.change_portstates(skey, state, ports, ports2)
    expect(result).to eq(nil)
  end

  it 'validate_persistentportstate' do
    skey = '10:00:50:EB:1A:A8:2C:54'
    ports = '10:00:00:00:00:00'
    ports2 = '10:00:00:00:00:01'
    state = 'enable'
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.change_persistentportstates(skey, state, ports, ports2)
    expect(result).to eq(nil)
  end

  it 'validate_changeportname' do
    skey = '10:00:50:EB:1A:A8:2C:54'
    port = '10:00:00:00:00:00'
    portname = 'testport'
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.set_portname(skey, port, portname)
    expect(result).to eq(nil)
  end

  it 'validate_getallzones_infabric' do
    fckey = '10:00:50:EB:1A:A8:2C:54'
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.zoneshow_all(fckey)
    expect(result.key?('zones')).to eq(true)
  end

  it 'validate_getactivezones_infabric' do
    fckey = '10:00:50:EB:1A:A8:2C:54'
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.zoneshow_all_active(fckey)
    expect(result.key?('zones')).to eq(true)
  end

  it 'validate_getdefinedzones_infabric' do
    fckey = '10:00:50:EB:1A:A8:2C:54'
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.zoneshow_all_defined(fckey)
    expect(result.key?('zones')).to eq(true)
  end

  it 'validate_getactivezone_infabric' do
    fckey = '10:00:50:EB:1A:A8:2C:54'
    zkey = 'test_zone'
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.zoneshow_active(fckey, zkey)
    expect(result.key?('zones')).to eq(true)
  end

  it 'validate_getdefinedzone_infabric' do
    fckey = '10:00:50:EB:1A:A8:2C:54'
    zkey = 'test_zone'
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.zoneshow_defined(fckey, zkey)
    expect(result.key?('zones')).to eq(true)
  end

  it 'validate_getzonedbs' do
    fckey = '10:00:50:EB:1A:A8:2C:54'
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.zonedbs(fckey)
    expect(result.key?('zonedbs')).to eq(true)
  end

  it 'validate_getaliases_infabric' do
    fckey = '10:00:50:EB:1A:A8:2C:54'
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.alishow(fckey)
    expect(result.key?('zoneAliases')).to eq(true)
  end

  it 'validate_getalias_info' do
    fckey = '10:00:50:EB:1A:A8:2C:54'
    zakey = '10:00:50:EB:1A:A8:2C:54'
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.alishow(fckey, zakey)
    expect(result.key?('zoneAliases')).to eq(true)
  end

  it 'validate_cfgshow_active' do
    fckey = '10:00:50:EB:1A:A8:2C:54'
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.cfgshow(fckey, 'active')
    expect(result.key?('zonesets')).to eq(true)
  end

  it 'validate_cfgshow_defined' do
    fckey = '10:00:50:EB:1A:A8:2C:54'
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.cfgshow(fckey, 'defined')
    expect(result.key?('zonesets')).to eq(true)
  end

  it 'validate_alicreate' do
    fckey = '10:00:50:EB:1A:A8:2C:54'
    aliname = 'test1_hba0'
    aliwwn  = '10:00:50:EB:1A:A8:2C:54'
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.alicreate(fckey, aliname, aliwwn)
    expect(result).to eq(nil)
  end

  it 'validate_aliadd' do
    fckey = '10:00:50:EB:1A:A8:2C:54'
    aliname = 'test1_hba0'
    aliwwn  = '10:00:50:EB:1A:A8:2C:54'
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.aliadd(fckey, aliname, aliwwn)
    expect(result).to eq(nil)
  end

  it 'validate_aliremove' do
    fckey = '10:00:50:EB:1A:A8:2C:54'
    aliname = 'test1_hba0'
    aliwwn  = '10:00:50:EB:1A:A8:2C:54'
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.aliremove(fckey, aliname, aliwwn)
    expect(result).to eq(nil)
  end

  it 'validate_transstart' do
    fckey = '10:00:50:EB:1A:A8:2C:54'
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.trans_start(fckey)
    expect(result).to eq(nil)
  end

  it 'validate_transcommit' do
    fckey = '10:00:50:EB:1A:A8:2C:54'
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.trans_commit(fckey)
    expect(result).to eq(nil)
  end

  it 'validate_transabort' do
    fckey = '10:00:50:EB:1A:A8:2C:54'
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.trans_abort(fckey)
    expect(result).to eq(nil)
  end

  it 'validate_zonecreate_standard' do
    fckey = '10:00:50:EB:1A:A8:2C:54'
    zonename = 'testzone'
    alitest1 = '10:00:50:EB:1A:A8:2C:54'
    alitest2 = '10:00:50:EB:1A:A8:2C:54'
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.zonecreate_standard(fckey, zonename, alitest1, alitest2)
    expect(result).to eq(nil)
  end

  it 'validate_zonecreate_peerzone' do
    fckey = '10:00:50:EB:1A:A8:2C:54'
    zonename = 'testzone'
    principal = ['10:00:50:EB:1A:A8:2C:54']
    members = ['10:00:50:EB:1A:A8:2C:54']
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.zonecreate_peerzone(fckey, zonename, principal: principal, members: members)
    expect(result).to eq(nil)
  end

  it 'validate_alidelete' do
    fckey = '10:00:50:EB:1A:A8:2C:54'
    alinames = ['test1_hba0']
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.alidelete(fckey, alinames)
    expect(result).to eq(nil)
  end

  it 'validate_zonedelete' do
    fckey = '10:00:50:EB:1A:A8:2C:54'
    zonenames = ['test1_zone']
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.alidelete(fckey, zonenames)
    expect(result).to eq(nil)
  end

  it 'validate_zoneadd_standard' do
    fckey = '10:00:50:EB:1A:A8:2C:54'
    zonename = 'test1_zone'
    aliname = 'test_ali1'
    aliname2 = 'test_ali2'
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.zoneadd_standard(fckey, zonename, aliname, aliname2)
    expect(result).to eq(nil)
  end

  it 'validate_zoneremove_standard' do
    fckey = '10:00:50:EB:1A:A8:2C:54'
    zonename = 'test1_zone'
    aliname = 'test_ali1'
    aliname2 = 'test_ali2'
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.zoneremove_standard(fckey, zonename, aliname, aliname2)
    expect(result).to eq(nil)
  end

  it 'validate_zoneadd_peerzone' do
    fckey = '10:00:50:EB:1A:A8:2C:54'
    zonename = 'test1_zone'
    principal = ['10:00:50:EB:1A:A8:2C:54']
    members = ['10:00:50:EB:1A:A8:2C:54']
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.zoneadd_standard(fckey, zonename, principal: principal, members: members)
    expect(result).to eq(nil)
  end

  it 'validate_zoneremove_peerzone' do
    fckey = '10:00:50:EB:1A:A8:2C:54'
    zonename = 'test1_zone'
    principal = ['10:00:50:EB:1A:A8:2C:54']
    members = ['10:00:50:EB:1A:A8:2C:54']
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.zoneremove_standard(fckey, zonename, principal: principal, members: members)
    expect(result).to eq(nil)
  end

  it 'validate_cfgadd' do
    fckey = '10:00:50:EB:1A:A8:2C:54'
    zonenames = ['test1_zone']
    cfgname = 'cfg_test'
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.cfgadd(fckey, cfgname, zonenames)
    expect(result).to eq(nil)
  end

  it 'validate_cfgremove' do
    fckey = '10:00:50:EB:1A:A8:2C:54'
    zonenames = ['test1_zone']
    cfgname = 'cfg_test'
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.cfgremove(fckey, cfgname, zonenames)
    expect(result).to eq(nil)
  end

  it 'validate_cfgenable' do
    fckey = '10:00:50:EB:1A:A8:2C:54'
    cfgname = 'cfg_test'
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.cfgenable(fckey, cfgname)
    expect(result).to eq(nil)
  end

  it 'validate_syslogevents' do
    count = '2'
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.syslog_events(count)
    expect(result.key?('events')).to eq(true)
  end

  it 'validate_trapevents' do
    count = '2'
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.trap_events(count)
    expect(result.key?('events')).to eq(true)
  end

  it 'validate_customevents' do
    startindex = '0'
    count = '2'
    origin = 'trap'
    severity = 'INFO'
    client = BrocadeAPIClient::Client.new(@url)
    client.login(@user, @password)
    result = client.custom_events(startindex, count, origin, severity)
    expect(result.key?('events')).to eq(true)
  end
end
