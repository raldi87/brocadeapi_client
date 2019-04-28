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
  # Evens REST API methods
  class Events
    def initialize(http_client)
      @http_client = http_client
      @base_url = '/resourcegroups/All/events'
    end

    def syslog_events(count = '10')
      api_url = @base_url + '?startindex=0&count=' + count + '&specialEvent=true&origin=syslog'
      _response, _body = @http_client.get(api_url)
    end

    def trap_events(count = '10')
      api_url = @base_url + '?startindex=0&count=' + count + '&specialEvent=true&origin=trap'
      _response, _body = @http_client.get(api_url)
    end

    def custom_events(startindex = '0', count = '10', origin = 'syslog', severity = 'INFO')
      api_url = @base_url + '?startindex=' + startindex + '&count=' + count + '&specialEvent=true' + '&origin=' + origin + '&severity=' + severity
      _response, _body = @http_client.get(api_url)
    end
  end
end
