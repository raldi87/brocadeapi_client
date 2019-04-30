# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.
require_relative 'exceptions'

module BrocadeAPIClient
  # Zones REST API Methods
  class Zones
    def initialize(http_client)
      @http_client = http_client
      @base_url = '/resourcegroups/All/fcfabrics/'
    end

    def zoneshow(fabrickey, zones = 'all', zkey = 'none')
      api_url = @base_url + fabrickey.upcase + '/zones'
      if zones == 'all'
      elsif zones == 'active'
        api_url += if zkey == 'none'
                     '?active=true'
                   else '/' + zkey + '-true'
                   end
      elsif zones == 'defined'
        api_url += if zkey == 'none'
                     '?active=false'
                   else '/' + zkey + '-false'
                   end
      else
        err_msg = 'Unsupported Zoning Option, supported ALL is without zonename'
        raise BrocadeAPIClient::UnsupportedOption.new(nil, err_msg)
      end
      _response, _body = @http_client.get(api_url)
    end

    def zonedbs(fabrickey)
      api_url = @base_url + fabrickey.upcase + '/zonedbs'
      _response, _body = @http_client.get(api_url)
    end

    def alishow(fabrickey, zakey = 'none')
      api_url = @base_url + fabrickey.upcase + '/zonealiases'
      if zakey == 'none'
        _response, _body = @http_client.get(api_url)
      else
        api_url += '/' + zakey.upcase
        _response, _body = @http_client.get(api_url)
      end
    end

    def cfgshow(fabrickey, type)
      api_url =  @base_url + fabrickey.upcase + '/zonesets'
      if type == 'all'
      elsif type == 'active'
        api_url += '?active=true'
      elsif type == 'defined'
        api_url +=  '?active=false'
      else puts 'Not supported'
      end
      _response, _body = @http_client.get(api_url)
    end

    def alicreate(fabrickey, aliname, *wwn)
      wwn.map!(&:upcase)
      api_url = @base_url + fabrickey.upcase + '/createzoningobject'
      alihash ||= { name: aliname, memberNames: wwn }
      (aliarray ||= []) << alihash
      payload ||= { zoneAliases: aliarray }
      _response, _body = @http_client.post(api_url, body: payload)
    end

    def control_transaction(fabrickey, action)
      payload ||= { lsanZoning: 'false', action: action.upcase }
      api_url = @base_url + fabrickey.upcase + '/controlzonetransaction'
      _response, _body = @http_client.post(api_url, body: payload)
    end

    def zonecreate_standard(fabrickey, zonename, *aliases)
      api_url = @base_url + fabrickey.upcase + '/createzoningobject'
      zonearray = []
      zonehash ||= { name: zonename, aliasNames: aliases, type: 'STANDARD' }
      (zonearray ||= []) << zonehash
      payload ||= { zones: zonearray }
      _response, _body = @http_client.post(api_url, body: payload)
    end

    def zonecreate_peerzone(fabrickey, zonename, **members)
      raise BrocadeAPIClient::InvalidPeerzoneOptions.new(nil, 'Use principal and members as hash keys') unless members.key?(:principal) && members.key?(:members)

      api_url = @base_url + fabrickey.upcase + '/createzoningobject'
      peermembers ||= { peerMemberName: members[:members] }
      peerdetails ||= { principalMemberName: members[:principal], peerMembers: peermembers }
      zonedetails ||= { name: zonename, type: 'STANDARD', peerZone: 'True', peerZoneDetails: peerdetails }
      (zonearray ||= []) << zonedetails
      payload ||= { zones: zonearray }
      _response, _body = @http_client.post(api_url, body: payload)
    end

    def zonedelete(fabrickey, *zonenames)
      api_url = @base_url + fabrickey.upcase + '/deletezoningobject'
      payload ||= { zoneNames: zonenames }
      _response, _body = @http_client.post(api_url, body: payload)
    end

    def alidelete(fabrickey, *alinames)
      api_url = @base_url + fabrickey.upcase + '/deletezoningobject'
      payload ||= { zoneAliasNames: alinames }
      _response, _body = @http_client.post(api_url, body: payload)
    end

    def altercfg(fabrickey, action, cfgname, *zonenames)
      api_url = @base_url + fabrickey.upcase + '/updatezoningobject'
      case action.upcase
      when 'ADD', 'REMOVE'
        payload ||= { action: action.upcase }
      else
        err_msg = 'Invalid Action selected, Allowed action is ADD/REMOVE'
        raise BrocadeAPIClient::UnsupportedOption.new(nil, err_msg)
      end
      cfghash ||= { name: cfgname, zoneNames: zonenames }
      (cfgarray ||= []) << cfghash
      payload.store(:zoneSets, cfgarray)
      _response, _body = @http_client.post(api_url, body: payload)
    end

    def alteralias(fabrickey, action, aliname, *wwn)
      api_url = @base_url + fabrickey.upcase + '/updatezoningobject'
      case action.upcase
      when 'ADD', 'REMOVE'
        payload ||= { action: action.upcase }
      else
        err_msg = 'Invalid Action selected, Allowed action is ADD/REMOVE'
        raise BrocadeAPIClient::UnsupportedOption.new(nil, err_msg)
      end
      wwn.map!(&:upcase)
      alihash ||= { name: aliname, memberNames: wwn }
      (aliarray ||= []) << alihash
      payload.store(:zoneAliases, aliarray)
      _response, _body = @http_client.post(api_url, body: payload)
    end

    def alterzoning_standard(fabrickey, action, zonename, *aliases)
      api_url = @base_url + fabrickey.upcase + '/updatezoningobject'
      case action.upcase
      when 'ADD', 'REMOVE'
        payload ||= { action: action.upcase }
      else
        err_msg = 'Invalid Action selected, Allowed action is ADD/REMOVE'
        raise BrocadeAPIClient::UnsupportedOption.new(nil, err_msg)
      end
      zonehash ||= { name: zonename, aliasNames: aliases }
      (zonearray ||= []) << zonehash
      payload.store(:zones, zonearray)
      _response, _body = @http_client.post(api_url, body: payload)
    end

    def alterzoning_peerzone(fabrickey, action, zonename, **wwn)
      api_url = @base_url + fabrickey.upcase + '/updatezoningobject'
      peerdetails = {}
      peermembers = {}
      case action.upcase
      when 'ADD', 'REMOVE'
        payload ||= { action: action.upcase }
      else
        err_msg = 'Invalid Action selected, Allowed action is ADD/REMOVE'
        raise BrocadeAPIClient::UnsupportedOption.new(nil, err_msg)
      end
      case (wwn.keys & %i[principal members]).sort
      when %i[members principal]
        wwn[:members].map!(&:upcase)
        wwn[:principal].map!(&:upcase)
        peermembers = { peerMemberName: wwn[:members] }
        peerdetails = { principalMemberName: wwn[:principal] }
      when [:principal]
        wwn[:principal].map!(&:upcase)
        peerdetails = { principalMemberName: wwn[:principal] }
      when [:members]
        wwn[:members].map!(&:upcase)
        peermembers = { peerMemberName: wwn[:members] }
      else
        err_msg = 'Invalid hash keys for peerzone, use principal and members when passing to function'
        raise BrocadeAPIClient::InvalidPeerzoneOptions.new(nil, err_msg)
      end
      puts peermembers
      peerdetails.store(:peerMembers, peermembers)
      zonedetails ||= { name: zonename, type: 'STANDARD', peerZone: 'True', peerZoneDetails: peerdetails }
      (zonearray ||= []) << zonedetails
      payload.store(:zones, zonearray)
      puts payload.to_json
      _response, _body = @http_client.post(api_url, body: payload)
    end

    def cfgenable(fabrickey, cfgname)
      api_url = @base_url + fabrickey.upcase + '/zonesets/' + cfgname + '-false/activate'
      payload = {}
      _response, _body = @http_client.post(api_url, body: payload)
    end
  end
end
