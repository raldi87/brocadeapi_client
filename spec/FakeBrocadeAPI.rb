
require 'sinatra'

class FakeBrocadeAPI < Sinatra::Base
  post '/rest/login' do
    response.headers['WStoken'] = "logintest"
  end

  post '/rest/logout' do
    status 204
  end
 
  get '/rest/resourcegroups' do
     json_response 200, 'resourcegroups.json' 

  end
  
  get '/rest/resourcegroups/All/fcfabrics' do
     json_response 200, 'resourcegroups.json'
  end
     

  private

  def json_response(response_code, file_name)
    content_type :json
    status response_code
    File.open(File.dirname(__FILE__) + '/json_files/' + file_name, 'rb').read
  end
end

