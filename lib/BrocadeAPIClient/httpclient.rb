# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.
require 'httparty'
require 'json'
require 'logger'
require_relative 'exceptions'

module BrocadeAPIClient
  # Class for talking to API
  class JSONRestClient
    USER_AGENT = 'ruby-brocadeclient'.freeze
    ACCEPT_TYPE = 'application/vnd.brocade.networkadvisor+json;version=v1'.freeze
    SESSION_COOKIE_NAME = 'WStoken'.freeze
    CONTENT_TYPE = 'application/vnd.brocade.networkadvisor+json;version=v1'.freeze
    attr_accessor :http_log_debug, :api_url, :session_key, :timeout, :secure,
                  :logger, :log_level
    @username = nil
    @password = nil
    def initialize(api_url, secure = false, http_log_debug = false,
                   client_logger = nil)
      @api_url = api_url
      @secure = secure
      @http_log_debug = http_log_debug
      @session_key = nil
      @client_logger = client_logger
      @httparty_log_level = :info
      @httparty_log_format = :logstash
      set_debug_flag
    end

    # This turns on/off http request/response debugging output to console
    def set_debug_flag
      if @http_log_debug
        @httparty_log_level = :debug
        @httparty_log_format = :curl
      end
    end

    def authenticate(user, password, _optional = nil)
      @username = user
      @pasword = password
      @session_key = nil
      auth_url = '/login'
      headers, _body = post(auth_url)
      @session_key = headers['WStoken']
    rescue StandardError => ex
      @client_logger.error('cannot login')
    end

    def url(api_url)
      # should be http://<Server:Port>/api/v1
      @api_url = api_url.chomp('/')
    end

    def get(url, **kwargs)
      headers, _payload = get_headers_and_payload(kwargs)
      response = HTTParty.get(api_url + url,
                              headers: headers,
                              verify: false, logger: @client_logger,
                              log_level: @httparty_log_level,
                              log_format: @client_logger)
      process_response(response)
    end

    def post(url, **kwargs)
      headers, payload = get_headers_and_payload(kwargs)
      response = HTTParty.post(api_url + url,
                               headers: headers,
                               body: payload,
                               verify: false,
                               logger: @client_logger,
                               log_level: @httparty_log_level,
                               log_format: @httparty_log_format)
      process_response(response)
    end

    def put(url, **kwargs)
      headers, payload = get_headers_and_payload(kwargs)
      response = HTTParty.put(api_url + url,
                              headers: headers,
                              body: payload,
                              verify: false, logger: @client_logger,
                              log_level: @httparty_log_level,
                              log_format: @httparty_log_format)
      process_response(response)
    end

    def delete(url, **kwargs)
      headers, _payload = get_headers_and_payload(kwargs)
      response = HTTParty.delete(api_url + url,
                                 headers: headers,
                                 verify: false, logger: @client_logger,
                                 log_level: @httparty_log_level,
                                 log_format: @httparty_log_format)
      process_response(response)
    end

    def process_response(response)
      headers = response.headers
      body = response.parsed_response
      if response.code != 200
        if body.nil?
          exception = BrocadeAPIClient.exception_from_response(response, body)
          @client_logger.error(exception)
          raise exception
        end
      end
      [headers, body]
    end

    def unauthenticate
      # delete the session on the brocade network advisor
      unless @session_key.nil?
        begin
          post('/logout')
        rescue StandardError
          @session_key = nil
        end
      end
    end

    def get_headers_and_payload(**kwargs)
      kwargs['headers'] = kwargs.fetch('headers', {})
      if session_key
        kwargs['headers'] = kwargs.fetch('headers', {})
        kwargs['headers'][SESSION_COOKIE_NAME] = session_key
      else
        kwargs['headers']['WSUsername'] = @username
        kwargs['headers']['WSPassword'] = @username
      end
      kwargs['headers']['User-Agent'] = USER_AGENT
      kwargs['headers']['Accept'] = ACCEPT_TYPE
      if kwargs.key?(:body)
        kwargs['headers']['Content-Type'] = CONTENT_TYPE
        kwargs[:body] = kwargs[:body].to_json
        payload = kwargs[:body]
      else
        payload = nil
      end
      [kwargs['headers'], payload]
    end
  end
end
