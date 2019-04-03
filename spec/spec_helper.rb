require "bundler/setup"
require 'webmock/rspec'
require_relative 'fake_brocade_api'


RSpec.configure do |config|
  config.before(:each) do
    stub_request(:any, /localhost/).to_rack(FakeBrocadeAPI)
  end
end
