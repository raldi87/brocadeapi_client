#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'BrocadeAPIClient/version'

Gem::Specification.new do |spec|
  spec.name          = 'brocade_api_client'
  spec.version       = BrocadeAPIClient::VERSION
  spec.authors       = ['Raldi87']
  spec.email         = ['dima.radu.lucian@gmail.com']

  spec.summary       = 'Brocade Network Advisor REST API Client'
  spec.description   = 'This gem is used query to Brocade Network Advisor via API'
  spec.homepage      = 'https://github.com/raldi87/brocadeapi_client'
  spec.license       = 'Apache-2.0'

  # Specify which files should be added to the gem when it is released.
  # The git ls-files -z
  # loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  
  spec.required_ruby_version = '~> 2.2.6'
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.66'
  spec.add_development_dependency 'sinatra', '~> 2.0', '>= 2.0.3'
  spec.add_development_dependency 'webmock', '~> 3.5', '>= 3.5.1'
  spec.add_runtime_dependency 'httparty', '~> 0.16.4'
end
