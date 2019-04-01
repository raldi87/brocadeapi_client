# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.
require_relative 'httpclient'
require_relative 'fabrics'
require_relative 'switches'
require_relative 'ports'
require_relative 'zones'
require_relative 'exceptions'

module BrocadeAPI_client
 
  class Client
       attr_reader :http
       def initialize(api_url,debug:false, secure: false, timeout: nil, app_type: 'ruby_brocade', log_file_path: nil)
             unless api_url.is_a?(String)
             raise BrocadeAPI_client::BrocadeException.new(nil,
                                                  "'api_url' parameter is mandatory and should be of type String")
             end
        @api_url = api_url
        @debug = debug
        puts debug
        @secure = secure
        @timeout = timeout
        @log_level = Logger::INFO
        @client_logger = nil
        @log_file_path = log_file_path
#      @log_file_path = "test.log"
        init_log
        @http = JSONRestClient.new(
             @api_url, @secure, @debug,
             @timeout = nil, @client_logger
        )
        @fabrics = Fabrics.new(@http)
        @switches = Switches.new(@http)
        @ports = Ports.new(@http)
        @zones = Zones.new(@http)
        @app_type = app_type
        end
      private def init_log
      # Create Logger 

            unless @log_file_path.nil?
                   @client_logger = Logger.new(@log_file_path, 'daily')
            else
                   @client_logger = Logger.new(STDOUT)
            end
            if @debug
                   @log_level = Logger::DEBUG
            end
      end


      def login(username, password, options=nil)
      # Authenticate on the Brocade Network Advisor API
            @http.authenticate(username,password,options)
      end


      def logout
      # Delete Session on REST API
          begin
             @http.unauthenticate
      #  @client_logger.close
          rescue BrocadeAPI_client::BrocadeException => ex
          # we dont do anything because Brocade Network Advisor return HTTP 204 if logout is OK and session was deleted
          end
      end
      
      
      # Get All networks 
      #
      #
      # ==== Returns
      # Hash with value as 
      # Array of Networks (FC + IP)
      def get_resourcegroups
         result = @http.get('/resourcegroups')
         result[1]
      end

      # Get All FC Fabrics
      #
      # 
      # ==== Returns
      # Hash with value as 
      # Array of Fabrics - Details of the ALL fabrics
      def get_fabrics
      # API GET for fabrics
         result = @fabrics.get_fabrics
         result[1]
      end

    
      # Get FC Fabric Information based on Fabric ID
      # 
      # fabricID = string containing fabricID , ex '10:00:00:00:00:00'
      # ==== Returns
      #
      # Hash  - Details of the specified fabric
      def get_fabric(fabricID)
         result = @fabrics.get_fabric(fabricID)
         result[1]
      end

      # Get FC switches members of a specific Fabric ID
      #
      # fabricID = string containing fabricID , ex '10:00:00:00:00:00'
      # ==== Returns
      #
      # Hash - with Value Array with all the switches part of fabricID
      def get_fabricswitches(fabricID)
         result = @switches.get_fabricswitches(fabricID)
         result[1]
      end


      
      # Get ALL FC Swiches in the Brocade Network Advisor
      #
      # 
      # ==== Returns
      #
      # Hash - Key fcswitches and Value of all the switches in BNA
      def get_allswitches
         result = @switches.get_allswitches
         result[1]
      end


      # Get ALL FC Ports in the Brocade Network Advisor
      #
      #
      # ==== Returns
      #
      # Hash - Key fcports , Value of all the ports in BNA
      def get_allports
         result = @ports.get_allports
         result[1]
      end

      # Change port states for on FC switch(non-persistent)
      # Input:
      # rgkey: - resource group ID(it can be retrived usint the get_resource method(ussualy the of the Fabric)
      # switchWWN -  switch WWN (it can be retrived using the get_Switches method)
      # portWWNs -  Array of PortWWN that should be changed
      # state - 'disabled|enable'
      # 
      # ==== Returns
      #
      # Hash - Key fcPortStateChangeResponseEntry  , Value Array of Hashes with all ports changed
      def change_portstates(rgkey,switchWWN,portWWNs,state)
         result = @ports.change_portstates(rgkey,switchWWN,portWWNs,state)
         result[1]
      end

      # Change port states for on FC switch(persistent)
      # Input:
      # rgkey: - resource group ID(it can be retrived usint the get_resource method(ussualy the of the Fabric)
      # switchWWN -  switch WWN (it can be retrived using the get_Switches method)
      # portWWNs -  Array of PortWWN that should be changed
      # state - 'disabled|enable'
      #
      # ==== Returns
      #
      # Hash - Key fcPortStateChangeResponseEntry  , Value Array of Hashes with all ports changed
      def change_persistentportstates(rgkey,switchWWN,portWWNs,state)
         result = @ports.change_persistentportstates(rgkey,switchWWN,portWWNs,state)
         result[1]
      end


      # Set Port Name for a specified port 
      # Input:
      # rgkey: - resource group ID(it can be retrived usint the get_resource method(ussualy the of the Fabric)
      # switchWWN -  switch WWN (it can be retrived using the get_Switches method)
      # portWWN -  Port WWN 
      # portNames - the name for the PortName
      #
      # ==== Returns
      #
      # Hash - Key fcPortStateChangeResponseEntry  , Value Array of Hashes with all ports changed
      def set_portname(rgkey,switchWWN,portWWNs,portName)
         result = @ports.set_portname(rgkey,switchWWN,portWWNs,portName)
         result[1]
      end
      
      # Get all Zones in a Fabric(both active and defined)
      # Input:
      # rgkey: - resource group ID(it can be retrived usint the get_resource method(ussualy the of the Fabric)
      # fabrickey - fabric key WWN(it can be retrived using the get_fabrics methond
      #
      # ==== Returns
      #
      # Hash - Key zones  , Value Array of Hashes with all zones
      def get_fabriczones_all(rgkey,fabrickey)
         result = @zones.get_allzonesinfabric(rgkey,fabrickey)
         result[1]  

      end
   
      # Get all Zones in a Fabric(active)
      # Input:
      # rgkey: - resource group ID(it can be retrived usint the get_resource method(ussualy the of the Fabric)
      # fabrickey - fabric key WWN(it can be retrived using the get_fabrics methond
      #
      # ==== Returns
      #
      # Hash - Key zones  , Value Array of Hashes with all zones

      def get_fabriczones_active(rgkey,fabrickey)
         result = @zones.get_allzonesinfabric(rgkey,fabrickey,zones: 'active')
         result[1]
      end

      # Get all Zones in a Fabric( defined)
      # Input:
      # rgkey: - resource group ID(it can be retrived usint the get_resource method(ussualy the of the Fabric)
      # fabrickey - fabric key WWN(it can be retrived using the get_fabrics methond
      #
      # ==== Returns
      #
      # Hash - Key zones  , Value Array of Hashes with all zones
      def get_fabriczones_defined(rgkey,fabrickey)
         result = @zones.get_allzonesinfabric(rgkey,fabrickey,zones: 'defined')
         result[1] 
      end
 




  end
end
