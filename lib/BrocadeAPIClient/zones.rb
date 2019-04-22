# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.

module BrocadeAPIClient
  # Zones REST API Methods
  class Zones
    def initialize(http_client)
      @http_client = http_client
      @base_url = '/resourcegroups/All'
    end

    def allzonesinfabric(fabrickey, zones = 'all')
      api_url = @base_url + '/fcfabrics/' + fabrickey + '/zones'
      if zones == 'all'
      elsif zones == 'active'
        api_url += '?active=true'
      elsif zones == 'defined'
        api_url += '?active=false'
      else 'Not supported'
      end
      _response, _body = @http_client.get(api_url)
    end

    def zonedbs(fabrickey)
      api_url = @base_url + '/fcfabrics/' + fabrickey + '/zonedbs'
      _response, _body = @http_client.get(api_url)
    end

    def alishow(fabrickey, zakey = 'none')
      api_url = @base_url + '/fcfabrics/' + fabrickey + '/zonealiases'
      if zakey == 'none'
        _response, _body = @http_client.get(api_url)
      else
        api_url += '/' + zakey
        _response, _body = @http_client.get(api_url)
      end
    end

    def cfgshow(fabrickey, type)
      api_url =  @base_url + '/fcfabrics/' + fabrickey + '/zonesets'
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
      aliarray = []
      alihash = {}
      payload = {}
      wwn.map!(&:upcase)
      api_url = @base_url + '/fcfabrics/' + fabrickey.upcase + '/createzoningobject'
      alihash['name'] = aliname
      alihash['memberNames'] = wwn
      aliarray.push(alihash)
      payload['zoneAliases'] = aliarray
      _response, _body = @http_client.post(api_url, body: payload)
    end

    def control_transaction(fabrickey, action)
      payload = {}
      payload['lsanZoning'] = 'false'
      payload['action'] = action.upcase
      api_url = @base_url + '/fcfabrics/' + fabrickey.upcase + '/controlzonetransaction'
      _response, _body = @http_client.post(api_url, body: payload)
    end
  end
end
