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
      @password = password
      @session_key = nil
      auth_url = '/login'
      headers, body = post(auth_url)
      @session_key = headers['WStoken']
      JSON.parse(body)
    rescue StandardError
      raise BrocadeAPIClient::ConnectionError
    end

    def url(api_url)
      # should be http://<Server:Port>/rest
      @api_url = api_url.chomp('/')
    end

    def get(url, **kwargs)
      headers, _payload = headers_payload(kwargs)
      response = HTTParty.get(api_url + url,
                              headers: headers,
                              verify: false, logger: @client_logger,
                              log_level: @httparty_log_level,
                              log_format: @client_logger)
      validate_answer(response)
    end

    def post(url, **kwargs)
      headers, payload = headers_payload(kwargs)
      response = HTTParty.post(api_url + url,
                               headers: headers,
                               body: payload,
                               verify: false,
                               logger: @client_logger,
                               log_level: @httparty_log_level,
                               log_format: @httparty_log_format)
      validate_answer(response)
    end

    def put(url, **kwargs)
      headers, payload = headers_payload(kwargs)
      response = HTTParty.put(api_url + url,
                              headers: headers,
                              body: payload,
                              verify: false, logger: @client_logger,
                              log_level: @httparty_log_level,
                              log_format: @httparty_log_format)
      validate_answer(response)
    end

    def delete(url, **kwargs)
      headers, _payload = headers_payload(kwargs)
      response = HTTParty.delete(api_url + url,
                                 headers: headers,
                                 verify: false, logger: @client_logger,
                                 log_level: @httparty_log_level,
                                 log_format: @httparty_log_format)
      validate_answer(response)
    end

    def validate_answer(response)
      headers = response.headers
      body = response.parsed_response
      code_array = %w[200 204]
      unless code_array.include?(response.code.to_s)
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
        post('/logout')
        @session_key = nil
      end
    end

    def headers_payload(**kwargs)
      kwargs['headers'] = kwargs.fetch('headers', {})
      if session_key
        kwargs['headers'] = kwargs.fetch('headers', {})
        kwargs['headers'][SESSION_COOKIE_NAME] = @session_key
      else
        kwargs['headers']['WSUsername'] = @username
        kwargs['headers']['WSPassword'] = @password
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
