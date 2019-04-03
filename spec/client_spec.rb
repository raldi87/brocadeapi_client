
require 'rspec'
require 'spec_helper'
require 'brocade_api_client'
require 'json'

describe "BrocadeAPIClient::Client" do

  before(:all) do
      @url = 'http://localhost/rest'
      @user = 'testuser'
      @password = 'password'
  end

  after(:all) do
      @url = nil
  end

  app_type= 'ruby-brocade'

  it 'validate_login' do
      session_key = 'logintest'
#      http = BrocadeAPIClient::JSONRestClient.new(@url, false, false, false, nil)
      client = BrocadeAPIClient::Client.new(@url)
      client.login(@user, @password)
      expect(client.http.session_key).to eq(session_key)
  end

  it 'validate_logout' do
#      http = BrocadeAPIClient::JSONRestClient.new(@url, false, false, false, nil)
      client = BrocadeAPIClient::Client.new(@url)
      client.login(@user, @password)
      client.logout
      expect(client.http.session_key).to eq(nil)
  end

  it 'validate_getresources' do
#      http = BrocadeAPIClient::JSONRestClient.new(@url, false, false, false, nil)
      client = BrocadeAPIClient::Client.new(@url)
      result = client.resourcegroups
      expect(result.has_key?("resourceGroups")).to eq(true)
  end

  it 'validate_getfabrics' do
#      http = BrocadeAPIClient::JSONRestClient.new(@url, false, false, false, nil)
      client = BrocadeAPIClient::Client.new(@url)
      result = client.fabrics
      expect(result.has_key?("fcFabrics")).to eq(true)
  end

  it 'validate_getfabrics_withinput' do
      input = "10:00:50:EB:1A:A8:2C:54"
      http = BrocadeAPIClient::JSONRestClient.new(@url, false, false, false, nil)
      client = BrocadeAPIClient::Client.new(@url)
      result = client.fabric(input)
      expect(result["fcFabrics"][0]["key"]).to eq(input)
  end

  it 'validate_getallswitches' do
      http = BrocadeAPIClient::JSONRestClient.new(@url, false, false, false, nil)
      client = BrocadeAPIClient::Client.new(@url)
      result = client.allswitches
      expect(result.has_key?("fcSwitches")).to eq(true)
  end

  it 'validate_getfabricswitches' do
      input = "10:00:00:05:1E:A5:59:B3"
      http = BrocadeAPIClient::JSONRestClient.new(@url, false, false, false, nil)
      client = BrocadeAPIClient::Client.new(@url)
      result = client.fabricswitches(input)
      expect(result.has_key?("fcSwitches")).to eq(true)
  end
end
