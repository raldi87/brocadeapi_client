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
  # Brocade Exception Classes
  class BrocadeException < StandardError
    attr_reader :message, :code, :ref, :http_status
    def initialize(code: nil, message: nil, ref: nil, http_status: nil)
      @code = code
      @message = message
      @ref = ref
      @http_status = http_status
      formatted_string = 'Error: '
      formatted_string += format(' (HTTP %s)', @http_status) if @http_status
      formatted_string += format(' API code: %s', @code) if @code
      formatted_string += format(' - %s', @message) if @message
      formatted_string += format(' - %s', @ref) if @ref
      super(formatted_string)
    end
  end
  exceptions_map = [{ name: 'UnsupportedOption' },
                    { name: 'UnsupportedVersion' },
                    { name: 'UnsupportedSeverityOption' },
                    { name: 'InvalidPeerzoneOptions' },
                    { name: 'InvalidVersion' },
                    { name: 'RequestException' },
                    { name: 'ConnectionError', message: 'Connection Error to Brocade Network Advisor version' },
                    { name: 'HTTPError' },
                    { name: 'URLRequired' },
                    { name: 'TooManyRedirects' },
                    { name: 'Timeout' },
                    { name: 'HTTPBadRequest', http_status: 400, message: 'Bad request'}, 
                    { name: 'HTTPUnauthorized',  http_status: 401, message: 'Unauthorized'},
                    { name: 'HTTPForbidden', http_status: 403, message: 'Forbidden'},
                    { name: 'HTTPNotFound', http_status: 404, message: 'Not found'},
                    { name: 'HTTPMethodNotAllowed', http_status: 405, message: 'Method Not Allowed'},
                    { name: 'HTTPNotAcceptable', http_status: 406, message: 'Method Not Acceptable'},
                    { name: 'HTTPProxyAuthRequired', http_status: 407, message: 'Proxy Authentication Required'},
                    { name: 'HTTPRequestTimeout', http_status: 408, message: 'Request Timeout'},
                    { name: 'HTTPConflict', http_status: 409, message: 'Conflict'},
                    { name: 'HTTPGone', http_status: 410, message: 'Gone'},
                    { name: 'HTTPLengthRequired', http_status: 411, message: 'Length Required'},
                    { name: 'HTTPPreconditionFailed', http_status: 412, message: 'Over limit'},
                    { name: 'HTTPRequestEntityTooLarge', http_status: 413, message: 'Request Entity Too Large'},
                    { name: 'HTTPRequestURITooLong', http_status: 414, message: 'Request URI Too Large'},
                    { name: 'HTTPUnsupportedMediaType', http_status: 415, message: 'Unsupported Media Type'},
                    { name: 'HTTPRequestedRangeNotSatisfiable', http_status: 416, message: 'Requested Range Not Satisfiable'},
                    { name: 'HTTPExpectationFailed', http_status: 417, message: 'Expectation Failed'},
                    { name: 'HTTPTeaPot', http_status: 418, message: 'I\'m A Teapot. (RFC 2324)'},
                    { name: 'HTTPInternalServerError', http_status: 500, message: 'Internal Server Error'},
                    { name: 'HTTPNotImplemented', http_status: 501, message: 'Not Implemented'},
                    { name: 'HTTPBadGateway', http_status: 502, message: 'Bad Gateway'},
                    { name: 'HTTPServiceUnavailable', http_status: 503, message: 'Service Unavailable'},
                    { name: 'HTTPGatewayTimeout', http_status: 504, message: 'Gateway Timeout'},
                    { name: 'HTTPVersionNotSupported', http_status: 505, message: 'Version Not Supported'}]

  exceptions_map.each { |x| BrocadeAPIClient.const_set(x[:name], BrocadeException.new(http_status: x[:http_status],message: x[:message])) }
  # Failed SSL cert class
  class SSLCertFailed < BrocadeException
    @http_status = ''
    @message = 'SSL Certificate Verification Failed'
  end

  attr_accessor :code_map
  @@code_map = Hash.new('BrocadeException')
  exceptions_map.each do |c|
     inst = BrocadeAPIClient.const_get(c[:name])
     @@code_map[inst.http_status] = c
  end
  def self.exception_from_response(response, _body)
    # Return an instance of an ClientException
    cls = @@code_map[response.code]
    BrocadeAPIClient.const_get(cls[:name])
  end
end
