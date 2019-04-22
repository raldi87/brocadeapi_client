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
  # Ports REST API Methods
  class Ports
    def initialize(http_client)
      @http_client = http_client
      @base_url = '/resourcegroups/All'
    end

    def allports
      api_url = @base_url + '/fcports'
      _response, _body = @http_client.get(api_url)
    end

    def change_portstates( switchwwn, state, *portwwns)
      payload = {}
      portwwns.map! { |x| x.upcase }
      api_url = @base_url + '/fcswitches/' + switchwwn.upcase + '/fcports/fcportstate'
      payload['fcPortState'] = state
      payload['fcPortWWNs'] = portwwns
      _response, _body = @http_client.post(api_url, body: payload)
    end

    def change_persistentportstates( switchwwn, state , *portwwns)
      payload = {}
      api_url = @base_url + '/fcswitches/' + switchwwn.upcase + '/fcports/fcportpersistentstate'
      portwwns.map! { |x| x.upcase }
      payload['fcPortState'] = state
      payload['fcPortWWNs'] = portwwns
      _response, _body = @http_client.post(api_url, body: payload)
    end

    def set_portname( switchwwn, portwwn, portname)
      porthash = {}
      portarray = []
      api_url = @base_url + '/fcswitches/' + switchwwn.upcase + '/fcports/fcportnames'
      porthash['fcPortWWN'] = portwwn.upcase
      porthash['fcPortName'] = portname
      portarray.push(porthash)
      payload = { 'fcPortNameChangeReqEntry' => portarray }
      _response, _body = @http_client.post(api_url, body: payload)
    end
  end
end
