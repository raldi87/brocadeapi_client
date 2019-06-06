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
require_relative 'apiversion'
require_relative 'static'
require_relative 'events'

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
      @events = Events.new(@http)
      @app_type = app_type
      @peer_zone_support = false
    end

    def login(username, password, options = nil)
      # Authenticate on the Brocade Network Advisor API
      login_info = @http.authenticate(username, password, options)
      api_v = APIVersion.parser(login_info['version'])
      min_api_version = APIVersion.parser(BrocadeAPIClient::BNASupport::BNA_MIN_SUPPORTED)
      min_peerzoning_version = APIVersion.parser(BrocadeAPIClient::BNASupport::BNA_PEER_ZONING_TDZ_MIN_SUPPORTED)
      if api_v < min_api_version
        err_msg = "Unsupported Brocade Network Advisor version #{api_v}, min supported version is, #{BrocadeAPIClient::BNASupport::BNA_MIN_SUPPORTED}"
        raise BrocadeAPIClient::UnsupportedVersion.new(nil, err_msg)
      end
      @peer_zone_support = true if api_v >= min_peerzoning_version
    end

    def logout
      # Delete Session on REST API
      @http.unauthenticate
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
    # fabrickey - fabric key WWN(it can be retrived using the fabrics methond
    #
    # ==== Returns
    #
    # Hash - Key zones  , Value Array of Hashes with all zones
    def zoneshow_all(fabrickey)
      result = @zones.zoneshow(fabrickey, 'all')
      result[1]
    end

    # Get all Zones in a Fabric(active)
    # Input:
    # fabrickey - fabric key WWN(it can be retrived
    #          using the fabrics methond
    #
    # ==== Returns
    #
    # Hash - Key zones  , Value Array of Hashes with all zones
    def zoneshow_all_active(fabrickey)
      result = @zones.zoneshow(fabrickey, 'active')
      result[1]
    end

    # Get all Zones in a Fabric( defined)
    # Input:
    # fabrickey - fabric key WWN(it can be retrived using the fabrics methond
    #
    # ==== Returns
    #
    # Hash - Key zones  , Value Array of Hashes with all zones
    def zoneshow_all_defined(fabrickey)
      result = @zones.zoneshow(fabrickey, 'defined')
      result[1]
    end

    # Get INFO about active zone in a Fabric( defined)
    # Input:
    # fabrickey - fabric key WWN(it can be retrived using the fabrics methond
    # zonename - string containing the zone name
    # ==== Returns
    #
    # Hash - Key zones  , Value Array of Hashes with all zones
    def zoneshow_active(fabrickey, zonename)
      result = @zones.zoneshow(fabrickey, 'active', zonename)
      result[1]
    end

    # Get INFO about a defined zone in a Fabric( defined)
    # Input:
    # fabrickey - fabric key WWN(it can be retrived using the fabrics methond
    # zonename - string containing the zone name
    # ==== Returns
    #
    # Hash - Key zones  , Value Array of Hashes with all zones
    def zoneshow_defined(fabrickey, zonename)
      result = @zones.zoneshow(fabrickey, 'defined', zonename)
      result[1]
    end

    # Create standard zone
    # Input:
    # fabrickey - fabric key WWN(it can be retrived using the fabrics methond
    # zonename - string containing the zone name
    # *aliases - list of aliases to be added in the zone
    # ==== Returns
    #
    # Hash - Key zones  , Value Array of Hashes with all zones
    def zonecreate_standard(fabrickey, zonename, *aliases)
      result = @zones.zonecreate_standard(fabrickey, zonename, *aliases)
      result[1]
    end

    # Create Peerzone
    # Input:
    # fabrickey - fabric key WWN(it can be retrived using the fabrics methond
    # zonename - string containing the zone name
    # *aliases - list of aliases to be added in the zone
    # ==== Returns
    #
    # Hash - Key zones  , Value Array of Hashes with all zones
    def zonecreate_peerzone(fabrickey, zonename, **members)
      unless @peer_zone_support
        err_msg = "Unsupported Brocade Network Advisor version #{api_v}, min supported version is, #{BrocadeAPIClient::BNASupport::BNA_PEER_ZONING_TDZ_MIN_SUPPORTED}"
        raise BrocadeAPIClient::UnsupportedVersion.new(nil, err_msg)
      end
      result = @zones.zonecreate_peerzone(fabrickey, zonename, **members)
      result[1]
    end

    # Delete Zones from defined configuration
    # Input:
    # fabrickey - fabric key WWN(it can be retrived using the fabrics methond
    # *zonenames - a list of zones to be delete
    # ==== Returns
    #
    # status of request
    def zonedelete(fabrickey, *zonenames)
      result = @zones.zonedelete(fabrickey, *zonenames)
      result[1]
    end

    # Add aliases to standard zone
    # Input:
    # fabrickey - fabric key WWN(it can be retrived using the fabrics methond
    # *aliasnames - a list of zones to be delete
    # ==== Returns
    #
    # status of request
    def zoneadd_standard(fabrickey, zonename, *aliases)
      result = @zones.alterzoning_standard(fabrickey, 'ADD', zonename, *aliases)
      result[1]
    end

    # Add aliases to standard zone
    # Input:
    # fabrickey - fabric key WWN(it can be retrived using the fabrics methond
    # *aliasnames - a list of zones to be delete
    # ==== Returns
    #
    # status of request
    def zoneremove_standard(fabrickey, zonename, *aliases)
      result = @zones.alterzoning_standard(fabrickey, 'REMOVE', zonename, *aliases)
      result[1]
    end

    # Add aliases to standard zone
    # Input:
    # fabrickey - fabric key WWN(it can be retrived using the fabrics methond
    # **wwns - hash with principal and members as keys and values as an array of wwns
    # ==== Returns
    #
    # status of request
    def zoneadd_peerzone(fabrickey, zonename, **wwns)
      result = @zones.alterzoning_peerzone(fabrickey, 'ADD', zonename, **wwns)
      result[1]
    end

    # Remove members/principal from peerzone
    # Input:
    # fabrickey - fabric key WWN(it can be retrived using the fabrics methond
    # **wwns - hash with principal and members as keys and values as an array of wwns
    # ==== Returns
    #
    # status of request
    def zoneremove_peerzone(fabrickey, zonename, **wwns)
      result = @zones.alterzoning_peerzone(fabrickey, 'REMOVE', zonename, **wwns)
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

    # Add zones to defined configuration
    # Input:
    # fabrickey - fabric key WWN(it can be retrived using the fabrics methond
    # cfgname - Fabric configuration name to which to add the zones
    # zonenames - list of zones to be added to the cfg
    # ==== Returns
    #
    # Status of request
    def cfgadd(fabrickey, cfgname, *zonenames)
      result = @zones.altercfg(fabrickey, 'ADD', cfgname, *zonenames)
      result[1]
    end

    # Remove zones to defined configuration
    # Input:
    # fabrickey - fabric key WWN(it can be retrived using the fabrics methond
    # cfgname - Fabric configuration name from which to remove the zones
    # zonenames - list of zones to be removed to the cfg
    # ==== Returns
    #
    # Status of request
    def cfgremove(fabrickey, cfgname, *zonenames)
      result = @zones.altercfg(fabrickey, 'REMOVE', cfgname, *zonenames)
      result[1]
    end

    # Enable defined zoning by configuration by name
    # Input:
    # fabrickey - fabric key WWN(it can be retrived using the fabrics methond
    # cfgname - Fabric configuration name from which to remove the zones
    # ==== Returns
    #
    # Status of request
    def cfgenable(fabrickey, cfgname)
      result = @zones.cfgenable(fabrickey, cfgname)
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

    # Add wwn to existing Alias
    # Input:
    # fabrickey - fabric key WWN(it can be retrived using the fabrics methond
    # aliname - name for new alias
    # wwn - to be added to aliname , it supports multiple wwns separated by comma
    # ==== Returns
    #
    # Status of request
    def aliadd(fabrickey, aliname, *wwn)
      result = @zones.alteralias(fabrickey, 'ADD', aliname, *wwn)
      result[1]
    end

    # Remove wwn to existing Alias
    # Input:
    # fabrickey - fabric key WWN(it can be retrived using the fabrics methond
    # aliname - name for new alias
    # wwn - to be added to aliname , it supports multiple wwns separated by comma
    # ==== Returns
    #
    # Status of request
    def aliremove(fabrickey, aliname, *wwn)
      result = @zones.alteralias(fabrickey, 'REMOVE', aliname, *wwn)
      result[1]
    end

    # Delete Aliases in defined Fabric
    # Input:
    # fabrickey - fabric key WWN(it can be retrived using the fabrics methond
    # alinames - list of aliases to be delete
    # ==== Returns
    #
    # Status of request
    def alidelete(fabrickey, *alinames)
      result = @zones.alidelete(fabrickey, *alinames)
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

    # Get syslog events
    # Input:
    # count -  String value to retrive the number of last events
    #
    # ==== Returns
    # Status of request
    def syslog_events(count)
      result = @events.syslog_events(count)
      result[1]
    end

    # Get trap events
    # Input:
    # count -  String value to retrive the number of last events
    #
    # ==== Returns
    # Status of request
    def trap_events(count)
      result = @events.trap_events(count)
      result[1]
    end

    # Get custom events based on params
    # Input:
    # count -  String value to retrive the number of last events
    #
    # ==== Returns
    # Status of request
    def custom_events(startindex = '0', count = '10', origin = 'syslog', severity = 'INFO')
      result = @events.custom_events(startindex, count, origin, severity)
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
