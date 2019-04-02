# Copyright 2016-2017 Hewlett Packard Enterprise Development LP
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.

module BrocadeAPI_client
        #Ports REST API Methods
	class Ports
             def initialize(http_client)
                 @http_client = http_client  
                 @base_url = '/resourcegroups/'
             end

             def get_allports
                 api_url =  @base_url + '/fcports'
                 response,body = @http_client.get(api_url)
             end
    
             def change_portstates(rgkey,switchWWN,portWWNs,state)
                 payload = {}
                 api_url = @base_url + rgkey + '/fcswitches/' + switchWWN + '/fcports/fcportstate'              
                 puts api_url
                 payload['fcPortState'] = state
                 payload['fcPortWWNs'] = portWWNs
                 response,body= @http_client.post(api_url, body: payload)

             end
             
             def change_persistentportstates(rgkey,switchWWN,portWWNs,state)
                 info = {}
                 api_url = @base_url + rgkey + '/fcswitches/' + switchWWN + '/fcports/fcportpersistentstate'
                 puts "radu: #{api_url}"
                 payload['fcPortState'] = state
                 payload['fcPortWWNs'] = portWWNs
                 response,body= @http_client.post(api_url, body: payload)

             end

             def set_portname(rgkey,switchWWN,portWWN,portName)
                 porthash = {}
                 portarray = []
                 payload = {}
                 api_url = @base_url + rgkey + '/fcswitches/' + switchWWN + '/fcports/fcportnames'
                 porthash['fcPortWWN'] = portWWN
                 porthash['fcPortName'] = portName
                 portarray.push(porthash)
                 payload = { 'fcPortNameChangeReqEntry' => portarray }
                 response,body= @http_client.post(api_url, body: payload)
             end

       end
end
