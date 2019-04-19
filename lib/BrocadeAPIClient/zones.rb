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
      @base_url = '/resourcegroups/'
    end

    def allzonesinfabric(rgkey, fabrickey, zones='all')
      api_url = @base_url + rgkey + '/fcfabrics/' + fabrickey + '/zones'
      p zones
      if zones == 'all'
        _response, _body = @http_client.get(api_url)
      elsif zones == 'active'
        api_url += '?active=true'
        p api_url
        _response, _body = @http_client.get(api_url)
      elsif zones == 'defined'
        api_url += '?active=false'
        p api_url
        _response, _body = @http_client.get(api_url)
      else 'Not supported'
      end
    end

    def zonedbs(fabrickey)
      api_url = @base_url + 'All/fcfabrics/' + fabrickey + '/zonedbs'
      puts api_url
      _response, _body = @http_client.get(api_url)
    end

    def alishow(rgkey, fabrickey, zakey='none')
      p zakey
      api_url = @base_url + rgkey + '/fcfabrics/' + fabrickey + '/zonealiases'
      if zakey == 'none'
      _response, _body = @http_client.get(api_url)
      else 
      api_url += '/' + zakey
      _response, _body = @http_client.get(api_url)
      end
    end

    def cfgshow(rgkey, fabrickey, type)
      puts rgkey
      puts fabrickey
      puts type
      api_url =  @base_url + rgkey + '/fcfabrics/' + fabrickey + '/zonesets'
      if type == 'all'
      elsif type == 'active'
        api_url += '?active=true'
      elsif type == 'defined'
        api_url +=  '?active=false'
      else puts 'Not supported'
      end
      puts api_url
      _response, _body = @http_client.get(api_url)
    end
  end
end
