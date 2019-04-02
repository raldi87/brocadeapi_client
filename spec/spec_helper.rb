require "bundler/setup"
require 'webmock/rspec'
require_relative 'FakeBrocadeAPI'
require 'BrocadeAPI_client'


RSpec.configure do |config|
  config.before(:each) do
    stub_request(:any, /localhost/).to_rack(FakeBrocadeAPI)
  end
end
