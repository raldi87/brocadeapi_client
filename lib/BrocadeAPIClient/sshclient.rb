# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.
require 'net/ssh'
require_relative 'exceptions'

module BrocadeAPIClient
  # SSH class to connect to switch
  class SSHClient
    attr_accessor :ip, :username, :password, :port, :conn_timeout, :privatekey, :http_log_debug, :logger
    def initialize(ip, username, password, port = nil, conn_timeout = nil, privatekey = nil)
      @ip = ip
      @username = username
      @password = password
      @port = port
      @conn_timeout = conn_timeout
      @privatekey = privatekey
      @http_log_debug = http_log_debug
    end

    def run(command)
      ssh = Net::SSH.start(@ip, @username, password: @password)
      stdout, _stederr = ssh.exec!(command)
      ssh.close
      stdout
    end
  end
end
