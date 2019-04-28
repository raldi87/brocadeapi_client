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
  # Class for checking supported API versions
  class APIVersion
    attr_accessor :major, :minor, :patch
    include Comparable
    def initialize(major, minor, patch)
      @major = major
      @minor = minor
      @patch = patch
    end

    def <=>(other)
      return -1 if major < other.major
      return 1 if major > other.major
      return -1 if minor < other.minor
      return 1 if minor > other.minor
      return -1 if patch < other.patch
      return 1 if patch > other.patch

      0
    end

    def self.validate(version)
      raise BrocadeAPIClient::InvalidVersion.new(nil, 'Invalid API Version Detected') if version.length != 3
    end

    def self.parser(version)
      version_array = version.split('.')
      validate(version_array)
      @major = version_array[0].to_i
      @minor = version_array[1].to_i
      @patch = version_array[2].to_i
      obj_v = APIVersion.new(@major, @minor, @patch)
      obj_v
    end
  end
end
