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

    def allzonesinfabric(rgkey, fabrickey, zones: 'all')
      if zones == 'all'
        api_url =  @base_url + rgkey + '/fcfabrics/' + fabrickey + '/zones'
        _response, _body = @http_client.get(api_url)
      elsif zones == 'active'
        api_url =  @base_url + rgkey + '/fcfabrics/' + fabrickey + '/zones?active=true'
        _response, _body = @http_client.get(api_url)
      elsif zones == 'defined'
        api_url =  @base_url + rgkey + '/fcfabrics/' + fabrickey + '/zones?active=false'
        _response, _body = @http_client.get(api_url)
      else 'Not supported'
      end
    end

    def zonedbs(fabrickey)
       api_url = @base_url + 'All/fcfabrics/' + fabrickey + '/zonedbs'
       puts api_url
       _response, _body = @http_client.get(api_url)
    end 
   
    def fabricaliases(rgkey, fabrickey)
       api_url =  @base_url + rgkey + '/fcfabrics/' + fabrickey + '/zonealiases'
       puts api_url
        _response, _body = @http_client.get(api_url)
    end

  end
end
