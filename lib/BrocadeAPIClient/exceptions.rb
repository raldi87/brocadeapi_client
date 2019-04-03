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
    def initialize(code = nil, message = nil, ref = nil, http_status = nil)
      @code = code
      @message = message
      @ref = ref
      @http_status = http_status
      formatted_string = 'Error: '
      if @http_status
        formatted_string += ' (HTTP %s)' % @http_status
      end
      if @code
        formatted_string += ' API code: %s' % @code
      end
      if @message
        formatted_string += ' - %s' % @message
      end
      if @ref
        formatted_string += ' - %s' % @ref
      end
      super(formatted_string)
    end
  end

  class UnsupportedVersion < BrocadeException
  end

  # Failed SSL cert class
  class SSLCertFailed < BrocadeException
    @http_status = ''
    @message = 'SSL Certificate Verification Failed'
  end

  class RequestException < BrocadeException
    # There was an ambiguous exception that occurred in Requests
  end

  class ConnectionError < BrocadeException
    # There was an error connecting to the server
  end

  class HTTPError < BrocadeException
    # An HTTP error occurred
  end

  class URLRequired < BrocadeException
    # A valid URL is required to make a request
  end

  class TooManyRedirects < BrocadeException
    # Too many redirects
  end

  class Timeout < BrocadeException
    # The request timed out
  end

  # 400 Errors
  # HTTP 400 - Bad request: you sent some malformed data.
  class HTTPBadRequest < BrocadeException
    attr_reader :message, :http_status
    def initialize(code = nil, message = nil, ref = nil, http_status = nil)
      @http_status = 400
      @message = 'Bad request'
      super(code, message.nil? ? @message : message,
            ref,
            http_status.nil? ? @http_status : http_status)
    end
  end

  # HTTP 401 - Unauthorized: bad credentials.
  class HTTPUnauthorized < BrocadeException
    attr_reader :message, :http_status
    def initialize(code = nil, message = nil, ref = nil, http_status = nil)
      @http_status = 401
      @message = 'Unauthorized'
      super(code, message.nil? ? @message : message,
            ref,
            http_status.nil? ? @http_status : http_status)
    end
  end

  # HTTP 403 - Forbidden: your credentials don't give you access to this
  # resource.
  class HTTPForbidden < BrocadeException
    attr_reader :message, :http_status
    def initialize(code = nil, message = nil, ref = nil, http_status = nil)
      @http_status = 403
      @message = 'Forbidden'
      super(code, message.nil? ? @message : message,
            ref,
            http_status.nil? ? @http_status : http_status)
    end
  end

  # HTTP 404 - Not found
  class HTTPNotFound < BrocadeException
    attr_reader :message, :http_status
    def initialize(code = nil, message = nil, ref = nil, http_status = nil)
      @http_status = 404
      @message = 'Not found'
      super(code, message.nil? ? @message : message,
            ref,
            http_status.nil? ? @http_status : http_status)
    end
  end

  # HTTP 405 - Method not Allowed
  class HTTPMethodNotAllowed < BrocadeException
    attr_reader :message, :http_status
    def initialize(code = nil, message = nil, ref = nil, http_status = nil)
      @http_status = 405
      @message = 'Method Not Allowed'
      super(code, message.nil? ? @message : message,
            ref,
            http_status.nil? ? @http_status : http_status)
    end
  end

  # HTTP 406 - Method not Acceptable
  class HTTPNotAcceptable < BrocadeException
    attr_reader :message, :http_status
    def initialize(code = nil, message = nil, ref = nil, http_status = nil)
      @http_status = 406
      @message = 'Method Not Acceptable'
      super(code, message.nil? ? @message : message,
            ref,
            http_status.nil? ? @http_status : http_status)
    end
  end

  # HTTP 407 - The client must first authenticate itself with the proxy.
  class HTTPProxyAuthRequired < BrocadeException
    attr_reader :message, :http_status
    def initialize(code = nil, message = nil, ref = nil, http_status = nil)
      @http_status = 407
      @message = 'Proxy Authentication Required'
      super(code, message.nil? ? @message : message,
            ref,
            http_status.nil? ? @http_status : http_status)
    end
  end

  # HTTP 408 - The server timed out waiting for the request.
  class HTTPRequestTimeout < BrocadeException
    attr_reader :message, :http_status
    def initialize(code = nil, message = nil, ref = nil, http_status = nil)
      @http_status = 408
      @message = 'Request Timeout'
      super(code, message.nil? ? @message : message,
            ref,
            http_status.nil? ? @http_status : http_status)
    end
  end

  # HTTP 409 - Conflict: A Conflict happened on the server
  class HTTPConflict < BrocadeException
    attr_reader :message, :http_status
    def initialize(code = nil, message = nil, ref = nil, http_status = nil)
      @http_status = 409
      @message = 'Conflict'
      super(code, message.nil? ? @message : message,
            ref,
            http_status.nil? ? @http_status : http_status)
    end
  end

  # HTTP 410 - Indicates that the resource requested is
  # no longer available and will not be available again.
  class HTTPGone < BrocadeException
    attr_reader :message, :http_status
    def initialize(code = nil, message = nil, ref = nil, http_status = nil)
      @http_status = 410
      @message = 'Gone'
      super(code, message.nil? ? @message : message,
            ref,
            http_status.nil? ? @http_status : http_status)
    end
  end

  # HTTP 411 - The request did not specify the length of its content, which is
  #           required by the requested resource.
  class HTTPLengthRequired < BrocadeException
    attr_reader :message, :http_status
    def initialize(code = nil, message = nil, ref = nil, http_status = nil)
      @http_status = 411
      @message = 'Length Required'
      super(code, message.nil? ? @message : message,
            ref,
            http_status.nil? ? @http_status : http_status)
    end
  end

  # HTTP 412 - The server does not meet one of the preconditions that the
  #           requester put on the request.
  class HTTPPreconditionFailed < BrocadeException
    attr_reader :message, :http_status
    def initialize(code = nil, message = nil, ref = nil, http_status = nil)
      @http_status = 412
      @message = 'Over limit'
      super(code, message.nil? ? @message : message,
            ref,
            http_status.nil? ? @http_status : http_status)
    end
  end

  # HTTP 413 - The request is larger than the server is willing or able to
  #           process
  class HTTPRequestEntityTooLarge < BrocadeException
    attr_reader :message, :http_status
    def initialize(code = nil, message = nil, ref = nil, http_status = nil)
      @http_status = 413
      @message = 'Request Entity Too Large'
      super(code, message.nil? ? @message : message,
            ref,
            http_status.nil? ? @http_status : http_status)
    end
  end

  # HTTP 414 - The URI provided was too long for the server to process.
  class HTTPRequestURITooLong < BrocadeException
    attr_reader :message, :http_status
    def initialize(code = nil, message = nil, ref = nil, http_status = nil)
      @http_status = 414
      @message = 'Request URI Too Large'
      super(code, message.nil? ? @message : message,
            ref,
            http_status.nil? ? @http_status : http_status)
    end
  end

  # HTTP 415 - The request entity has a media type which the server or resource
  #           does not support.
  class HTTPUnsupportedMediaType < BrocadeException
    attr_reader :message, :http_status
    def initialize(code = nil, message = nil, ref = nil, http_status = nil)
      @http_status = 415
      @message = 'Unsupported Media Type'
      super(code, message.nil? ? @message : message,
            ref,
            http_status.nil? ? @http_status : http_status)
    end
  end

  # HTTP 416 - The client has asked for a portion of the file, but the server
  #           cannot supply that portion.
  class HTTPRequestedRangeNotSatisfiable < BrocadeException
    attr_reader :message, :http_status
    def initialize(code = nil, message = nil, ref = nil, http_status = nil)
      @http_status = 416
      @message = 'Requested Range Not Satisfiable'
      super(code, message.nil? ? @message : message,
            ref,
            http_status.nil? ? @http_status : http_status)
    end
  end

  # HTTP 417 - The server cannot meet the requirements of the Expect
  #           request-header field.
  class HTTPExpectationFailed < BrocadeException
    attr_reader :message, :http_status
    def initialize(code = nil, message = nil, ref = nil, http_status = nil)
      @http_status = 417
      @message = 'Expectation Failed'
      super(code, message.nil? ? @message : message,
            ref,
            http_status.nil? ? @http_status : http_status)
    end
  end

  # HTTP 418 - I'm a Tea Pot
  class HTTPTeaPot < BrocadeException
    attr_reader :message, :http_status
    def initialize(code = nil, message = nil, ref = nil, http_status = nil)
      @http_status = 418
      @message = 'I' 'm A Teapot. (RFC 2324)'
      super(code, message.nil? ? @message : message,
            ref,
            http_status.nil? ? @http_status : http_status)
    end
  end
  # 500 Errors
  # HTTP 500 - Internal Server Error: an internal error occured.
  class HTTPInternalServerError < BrocadeException
    attr_reader :message, :http_status
    def initialize(code = nil, message = nil, ref = nil, http_status = nil)
      @http_status = 500
      @message = 'Internal Server Error'
      super(code, message.nil? ? @message : message,
            ref,
            http_status.nil? ? @http_status : http_status)
    end
  end

  # HTTP 501 - Not Implemented: the server does not support this operation.
  class HTTPNotImplemented < BrocadeException
    attr_reader :message, :http_status
    def initialize(code = nil, message = nil, ref = nil, http_status = nil)
      @http_status = 501
      @message = 'Not Implemented'
      super(code, message.nil? ? @message : message,
            ref,
            http_status.nil? ? @http_status : http_status)
    end
  end

  # HTTP 502 - The server was acting as a gateway or proxy and received an
  #           invalid response from the upstream server.
  class HTTPBadGateway < BrocadeException
    attr_reader :message, :http_status
    def initialize(code = nil, message = nil, ref = nil, http_status = nil)
      @http_status = 502
      @message = 'Bad Gateway'
      super(code, message.nil? ? @message : message,
            ref,
            http_status.nil? ? @http_status : http_status)
    end
  end

  # HTTP 503 - The server is currently unavailable
  class HTTPServiceUnavailable < BrocadeException
    attr_reader :message, :http_status
    def initialize(code = nil, message = nil, ref = nil, http_status = nil)
      @http_status = 503
      @message = 'Service Unavailable'
      super(code, message.nil? ? @message : message,
            ref,
            http_status.nil? ? @http_status : http_status)
    end
  end

  # HTTP 504 - The server was acting as a gateway or proxy and did
  #          not receive a timely response from the upstream server.
  class HTTPGatewayTimeout < BrocadeException
    attr_reader :message, :http_status
    def initialize(code = nil, message = nil, ref = nil, http_status = nil)
      @http_status = 504
      @message = 'Gateway Timeout'
      super(code, message.nil? ? @message : message,
            ref,
            http_status.nil? ? @http_status : http_status)
    end
  end

  # HTTP 505 - The server does not support the HTTP protocol version used
  #           in the request.
  class HTTPVersionNotSupported < BrocadeException
    attr_reader :message, :http_status
    def initialize(code = nil, message = nil, ref = nil, http_status = nil)
      @http_status = 505
      @message = 'Version Not Supported'
      super(code, message.nil? ? @message : message,
            ref,
            http_status.nil? ? @http_status : http_status)
    end
  end
  attr_accessor :code_map
  @@code_map = Hash.new('BrocadeException')
  exp = ['HTTPBadRequest', 'HTTPUnauthorized',
         'HTTPForbidden', 'HTTPNotFound', 'HTTPMethodNotAllowed',
         'HTTPNotAcceptable', 'HTTPProxyAuthRequired',
         'HTTPRequestTimeout', 'HTTPConflict', 'HTTPGone',
         'HTTPLengthRequired', 'HTTPPreconditionFailed',
         'HTTPRequestEntityTooLarge', 'HTTPRequestURITooLong',
         'HTTPUnsupportedMediaType', 'HTTPRequestedRangeNotSatisfiable',
         'HTTPExpectationFailed', 'HTTPTeaPot',
         'HTTPNotImplemented', 'HTTPBadGateway',
         'HTTPServiceUnavailable', 'HTTPGatewayTimeout',
         'HTTPVersionNotSupported', 'HTTPInternalServerError']
  exp.each do |c|
    inst = BrocadeAPIClient.const_get(c).new
    @@code_map[inst.http_status] = c
  end
  def self.exception_from_response(response, body)
    # Return an instance of an ClientException
    #
    cls = @@code_map[response.code]
    code = nil
    msg = nil
    ref = nil
    return BrocadeAPIClient.const_get(cls).new(code, msg, ref, response.code)
  end
end
