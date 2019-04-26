# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.
require_relative 'client'
require_relative 'httpclient'
module BrocadeAPIClient
  # Fabrics REST API Methods
  class Fabrics
    def initialize(http_client)
      @http_client = http_client
      @fabrics_url = '/resourcegroups/All/fcfabrics'
    end

    def fabrics
      _response, _body = @http_client.get(@fabrics_url)
    end

    def fabric(fabricid)
      _response, _body = @http_client.get(@fabrics_url + '/' + fabricid.upcase)
    end
  end
end
