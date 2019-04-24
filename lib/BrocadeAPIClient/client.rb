# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.
require_relative 'httpclient'
require_relative 'fabrics'
require_relative 'switches'
require_relative 'ports'
require_relative 'zones'
require_relative 'exceptions'

module BrocadeAPIClient
  # Class for connecting to BNA
  class Client
    @http = nil
    attr_reader :http, :logger
    def initialize(api_url, debug: false, secure: false, app_type: 'ruby_brocade', enable_logger: nil, log_file_path: nil)
      unless api_url.is_a?(String)
        raise BrocadeAPIClient::BrocadeException.new(nil,
                                                     "'api_url' parameter is mandatory and should be of type String")
      end
      @api_url = api_url
      @debug = debug
      @secure = secure
      @log_level = Logger::INFO
      @enable_logger = enable_logger
      @client_logger = nil
      @log_file_path = log_file_path
      init_log
      @http = JSONRestClient.new(
        @api_url, @secure, @debug,
        @client_logger
      )
      @fabrics = Fabrics.new(@http)
      @switches = Switches.new(@http)
      @ports = Ports.new(@http)
      @zones = Zones.new(@http)
      @app_type = app_type
    end

    def login(username, password, options = nil)
      # Authenticate on the Brocade Network Advisor API
      @http.authenticate(username, password, options)
    end

    def logout
      # Delete Session on REST API
      @http.unauthenticate
    rescue BrocadeAPIClient::BrocadeException => ex
      # we dont do anything because Brocade Network Advisor
      # return HTTP 204 if logout is OK and session was deleted
    end

    # Get All networks
    #
    #
    # ==== Returns
    # Hash with value as
    # Array of Networks (FC + IP)
    def resourcegroups
      result = @http.get('/resourcegroups')
      result[1]
    end

    # Get All FC Fabrics
    #
    #
    # ==== Returns
    # Hash with value as
    # Array of Fabrics - Details of the ALL fabrics
    def fabrics
      # API GET for fabrics
      result = @fabrics.fabrics
      result[1]
    end

    # Get FC Fabric Information based on Fabric ID
    #
    # fabricID = string containing fabricID , ex '10:00:00:00:00:00'
    # ==== Returns
    #
    # Hash  - Details of the specified fabric
    def fabric(fabricid)
      result = @fabrics.fabric(fabricid)
      result[1]
    end

    # Get FC switches members of a specific Fabric ID
    #
    # fabricID = string containing fabricID , ex '10:00:00:00:00:00'
    # ==== Returns
    #
    # Hash - with Value Array with all the switches part of fabricID
    def fabricswitches(fabricid)
      result = @switches.fabricswitches(fabricid)
      result[1]
    end

    # Get ALL FC Swiches in the Brocade Network Advisor
    #
    #
    # ==== Returns
    #
    # Hash - Key fcswitches and Value of all the switches in BNA
    def allswitches
      result = @switches.allswitches
      result[1]
    end

    # Get ALL FC Ports in the Brocade Network Advisor
    #
    #
    # ==== Returns
    #
    # Hash - Key fcports , Value of all the ports in BNA
    def allports
      result = @ports.allports
      result[1]
    end

    # Change port states for on FC switch(non-persistent)
    # Input:
    # switchWWN -  switch WWN (it can be retrived using the Switches method)
    # portWWNs -  Multiple PortWWN in the same switch that should be changed
    # state - 'disabled|enable'
    #
    # ==== Returns
    #
    # Hash - Key fcPortStateChangeResponseEntry  , Value Array of Hashes with all ports changed
    def change_portstates(switchwwn, state, *portwwns)
      result = @ports.change_portstates(switchwwn, state, *portwwns)
      result[1]
    end

    # Change port states for on FC switch(persistent)
    # Input:
    # switchWWN -  switch WWN (it can be retrived using the Switches method)
    # portWWNs -  Multiple PortWWN in same switch that should be changed
    # state - 'disabled|enable'
    #
    # ==== Returns
    #
    # Hash - Key fcPortStateChangeResponseEntry  , Value Array of Hashes with all ports changed
    def change_persistentportstates(switchwwn, state, *portwwns)
      result = @ports.change_persistentportstates(switchwwn, state, *portwwns)
      result[1]
    end

    # Set Port Name for a specified port
    # Input:
    # the resource method(ussualy the of the Fabric)
    # switchWWN -  switch WWN (it can be retrived using the Switches method)
    # portWWN -  Port WWN
    # portNames - the name for the PortName
    #
    # ==== Returns
    #
    # Hash - Key fcPortStateChangeResponseEntry  , Value Array of Hashes with all ports changed
    def set_portname(switchwwn, portwwns, portname)
      result = @ports.set_portname(switchwwn, portwwns, portname)
      result[1]
    end

    # Get all Zones in a Fabric(both active and defined)
    # Input:
    # rgkey: - resource group ID(it can be retrived using
    # the resource method(ussualy the of the Fabric)
    # fabrickey - fabric key WWN(it can be retrived using the fabrics methond
    #
    # ==== Returns
    #
    # Hash - Key zones  , Value Array of Hashes with all zones
    def zoneshow(fabrickey)
      result = @zones.zoneshow(fabrickey)
      result[1]
    end

    # Get all Zones in a Fabric(active)
    # Input:
    # rgkey: - resource group ID(it can be retrived using
    #          the resource method(ussualy the of the Fabric)
    # fabrickey - fabric key WWN(it can be retrived
    #          using the fabrics methond
    #
    # ==== Returns
    #
    # Hash - Key zones  , Value Array of Hashes with all zones
    def zoneshow_active(fabrickey)
      result = @zones.zoneshow(fabrickey, 'active')
      result[1]
    end

    # Get all Zones in a Fabric( defined)
    # Input:
    # rgkey: - resource group ID(it can be retrived using
    #         the resource method(ussualy the of the Fabric)
    # fabrickey - fabric key WWN(it can be retrived using the fabrics methond
    #
    # ==== Returns
    #
    # Hash - Key zones  , Value Array of Hashes with all zones
    def zoneshow_defined(fabrickey)
      result = @zones.zoneshow(fabrickey, 'defined')
      result[1]
    end

    # Get Zone DB in a fabric(active and defined)
    # Input:
    # fabrickey - fabric key WWN(it can be retrived using the fabrics methond
    #
    # ==== Returns
    #
    # Hash - Key zones  , Value Array of Hashes with all zones
    def zonedbs(fabrickey)
      result = @zones.zonedbs(fabrickey)
      result[1]
    end

    # Get Zone Aliases in a fabric
    # Input:
    # fabrickey - fabric key WWN(it can be retrived using the fabrics methond
    #
    # ==== Returns
    #
    # Hash - Key zoneAliases , Value Array of Hashes with all aliases
    def alishow(fabrickey, zakey = 'none')
      result = @zones.alishow(fabrickey, zakey)
      result[1]
    end

    # Get Fabric configuration
    # Input:
    # fabrickey - fabric key WWN(it can be retrived using the fabrics methond
    #
    # ==== Returns
    #
    # Hash - Key zoneAliases , Value Array of Hashes with all aliases
    def cfgshow(fabrickey, type)
      result = @zones.cfgshow(fabrickey, type)
      result[1]
    end

    # Create Zone Aliases in a fabric
    # Input:
    # fabrickey - fabric key WWN(it can be retrived using the fabrics methond
    # aliname - name for new alias
    # wwn - to be added to aliname , it supports multiple wwns separated by comma
    # ==== Returns
    #
    # Status of request
    def alicreate(fabrickey, aliname, *wwn)
      result = @zones.alicreate(fabrickey, aliname, *wwn)
      result[1]
    end

    # Start Fabric transaction
    # Input:
    # fabrickey - fabric key WWN(it can be retrived using the fabrics methond
    #
    # ==== Returns
    # Status of request
    def trans_start(fabrickey)
      result = @zones.control_transaction(fabrickey, 'start')
      result[1]
    end

    # Commit Fabric transaction
    # Input:
    # fabrickey - fabric key WWN(it can be retrived using the fabrics methond
    #
    # ==== Returns
    # Status of request
    def trans_commit(fabrickey)
      result = @zones.control_transaction(fabrickey, 'commit')
      result[1]
    end

    # Abort Fabric transaction
    # Input:
    # fabrickey - fabric key WWN(it can be retrived using the fabrics methond
    #
    # ==== Returns
    # Status of request
    def trans_abort(fabrickey)
      result = @zones.control_transaction(fabrickey, 'abort')
      result[1]
    end

    private

    def init_log
      # Create Logger
      @client_logger = if @enable_logger
                         if @log_file_path.nil?
                           Logger.new(STDOUT)
                         else
                           Logger.new(@log_file_path, 'daily')
                         end
                       else @enable_logger = false
                       end

      @log_level = Logger::DEBUG if @debug
    end
  end
end
