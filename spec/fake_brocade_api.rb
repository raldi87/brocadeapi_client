# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.
require 'sinatra'

# Fake Sinatra implementation for test response
class FakeBrocadeAPI < Sinatra::Base
  post '/rest/login' do
    response.headers['WStoken'] = 'logintest'
    status 200
    values = File.open(File.dirname(__FILE__) + '/json_files/login.json', 'rb').read
    values
  end

  post '/rest/logout' do
    json_response 204, 'logout.json'
  end

  get '/rest/resourcegroups' do
    json_response 200, 'resourcegroups.json'
  end

  get '/rest/resourcegroups/All/fcfabrics' do
    json_response 200, 'fabrics.json'
  end

  get '/rest/resourcegroups/All/fcfabrics/*/fcswitches' do
    json_response 200, 'switches.json'
  end

  get '/rest/resourcegroups/All/fcfabrics/*/zonedbs' do
    json_response 200, 'zonedbs.json'
  end

  get '/rest/resourcegroups/All/fcfabrics/*/zones' do
    json_response 200, 'zones.json'
  end

  get '/rest/resourcegroups/All/fcfabrics/*/zonealiases*' do
    json_response 200, 'aliases.json'
  end

  get '/rest/resourcegroups/All/fcfabrics/*/zonesets' do
    if params[:active]
      json_response 200, 'cfg_active.json'
    else
      json_response 200, 'cfg_defined.json'
    end
  end

  get '/rest/resourcegroups/All/fcfabrics/*/zones/*' do
    json_response 200, 'zones.json'
  end

  get '/rest/resourcegroups/All/fcfabrics/*' do
    json_response 200, 'fabrics_withinput.json'
  end

  get '/rest/resourcegroups/All/fcswitches' do
    json_response 200, 'switches.json'
  end

  get '/rest/resourcegroups/All/fcports' do
    json_response 200, 'ports.json'
  end

  post '/rest/resourcegroups/All/fcswitches/*/fcports/fcportstate' do
    content_type :json
    hashkey = %w[fcPortState fcPortWWNs]
    post_response 200, JSON.parse(request.body.read), hashkey
  end

  post '/rest/resourcegroups/All/fcswitches/*/fcports/fcportpersistentstate' do
    content_type :json
    hashkey = %w[fcPortState fcPortWWNs]
    post_response 200, JSON.parse(request.body.read), hashkey
  end

  post '/rest/resourcegroups/All/fcswitches/*/fcports/fcportnames' do
    content_type :json
    input = JSON.parse(request.body.read)
    status 200 if input.key?('fcPortNameChangeReqEntry')
  end

  get '/rest/resourcegroups/All/events' do
    json_response 200, 'events.json'
  end

  post '/rest/resourcegroups/All/fcfabrics/*/controlzonetransaction' do
    content_type :json
    input = JSON.parse(request.body.read)
    case input['action']
    when 'START'
      status 200
    when 'COMMIT'
      status 200
    when 'ABORT'
      status 200
    else
      status 666
    end
  end

  post '/rest/resourcegroups/All/fcfabrics/*/createzoningobject' do
    content_type :json
    input = JSON.parse(request.body.read)
    status 200 if input.key?('zoneAliases') || input.key?('zones')
  end

  post '/rest/resourcegroups/All/fcfabrics/*/deletezoningobject' do
    content_type :json
    input = JSON.parse(request.body.read)
    status 200 if input.key?('zoneAliasNames') || input.key?('zoneNames')
  end

  post '/rest/resourcegroups/All/fcfabrics/*/updatezoningobject' do
    content_type :json
    input = JSON.parse(request.body.read)
    status 200 if input.key?('zoneSets') || input.key?('zones') || input.key?('zoneAliases')
  end

  post '/rest/resourcegroups/All/fcfabrics/*/zonesets/*/activate' do
    content_type :json
    input = JSON.parse(request.body.read)
    status 200 if input.empty?
  end

  private

  def json_response(response_code, file_name)
    content_type :json
    status response_code
    File.open(File.dirname(__FILE__) + '/json_files/' + file_name, 'rb').read
  end

  def post_response(_response_code, post_input, hashkeys)
    content_type :json
    if post_input.key?(hashkeys[0]) && post_input.key?(hashkeys[1])
      status 200
    else status 204
    end
  end
end
