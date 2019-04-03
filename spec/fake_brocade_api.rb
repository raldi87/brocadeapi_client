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
  end

  post '/rest/logout' do
    status 204
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

  get '/rest/resourcegroups/All/fcfabrics/*' do
    json_response 200, 'fabrics_withinput.json'
  end

  get '/rest/resourcegroups/All/fcswitches' do
    json_response 200, 'switches.json'
  end

  private

  def json_response(response_code, file_name)
    content_type :json
    status response_code
    File.open(File.dirname(__FILE__) + '/json_files/' + file_name, 'rb').read
  end
end
