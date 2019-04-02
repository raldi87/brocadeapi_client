
require 'rspec'
require 'spec_helper'
require 'BrocadeAPI_client'
require 'json'

describe "BrocadeAPI_client::Client" do

  before(:all) do
      @url = "http://localhost/rest"
      @user = "testuser"
      @password = "password"
  end
  
  after(:all) do
      @url = nil
  end

  app_type= "ruby-brocade"

  it 'validate_login' do
      session_key = "logintest"
      http = BrocadeAPI_client::JSONRestClient.new(@url, false, false, false, nil)    
      client = BrocadeAPI_client::Client.new(@url)
      client.login(@user, @password)
      expect(client.http.session_key).to eq(session_key)
  end

  it 'validate_logout' do
      http = BrocadeAPI_client::JSONRestClient.new(@url, false, false, false, nil)
      client = BrocadeAPI_client::Client.new(@url)
      client.login(@user, @password)
      client.logout
      expect(client.http.session_key).to eq(nil)
  end

  it 'validate_getresources' do
      http = BrocadeAPI_client::JSONRestClient.new(@url, false, false, false, nil)
      client = BrocadeAPI_client::Client.new(@url)  
      result = client.get_resourcegroups
      expect(result.has_key?("resourceGroups")).to eq(true)
  end


  it 'validate_getfabrics' do
      http = BrocadeAPI_client::JSONRestClient.new(@url, false, false, false, nil)
      client = BrocadeAPI_client::Client.new(@url)
      result = client.get_fabrics
      expect(result.has_key?("fcFabrics")).to eq(true)
  end
 
  
  it 'validate_getfabrics_withinput' do
      input = "10:00:50:EB:1A:A8:2C:54"
      http = BrocadeAPI_client::JSONRestClient.new(@url, false, false, false, nil)
      client = BrocadeAPI_client::Client.new(@url)
      result = client.get_fabric(input)
      expect(result["fcFabrics"][0]["key"]).to eq(input)
  end

  it 'validate_getallswitches' do
      http = BrocadeAPI_client::JSONRestClient.new(@url, false, false, false, nil)
      client = BrocadeAPI_client::Client.new(@url)
      result = client.get_allswitches
      expect(result.has_key?("fcSwitches")).to eq(true)
  end

  it 'validate_getfabricswitches' do
      input = "10:00:00:05:1E:A5:59:B3"
      http = BrocadeAPI_client::JSONRestClient.new(@url, false, false, false, nil)
      client = BrocadeAPI_client::Client.new(@url)
      result = client.get_fabricswitches(input)
      expect(result.has_key?("fcSwitches")).to eq(true)
  end

end
