require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'sinatra_webservice'

require 'net/http'

class SinatraWebService::TestClient
  attr_accessor :host, :port

  def initialize( app )
    @host, @port = app.host, app.port
  end

  def get(action)
    res = Net::HTTP.start(self.host, self.port) do |http|
      http.get(action)
    end
  end
  
  def delete(action, data = "", headers = nil, dest = nil)
    data = data.empty? ? "_method=delete" : data += "&_method=delete"
    post(action, data, headers, dest)
  end
  
  def put(action, data = "", headers = nil, dest = nil)
    data = data.empty? ? "_method=put" : data += "&_method=put"
    post(action, data, headers, dest)
  end
  
  def post(action, data, headers = nil, dest = nil)
    res = Net::HTTP.start(self.host, self.port) do |http|
      http.post(action, data, headers, dest)
    end
  end
end
