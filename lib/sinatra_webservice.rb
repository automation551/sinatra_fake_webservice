require 'net/http'
require 'sinatra/base'
require 'socket'

class SinatraWebService
  
  attr_accessor :host, :port
  attr_accessor :current_thread
  
  class SinatraStem < Sinatra::Base      
    enable :methodoverride
  end
  
  
  def initialize(options = {})
    @host = options[:host] ||= 'localhost'
    @port = options[:port] ||= 4567
  end
  
  def running?
    self.current_thread.alive? rescue false
  end

  def run!
    if Thread.list.size > 2
      Thread.list.first.kill
    end
    
    find_free_port
    
    self.current_thread = Thread.new do
      SinatraStem.run! :post => @host, :port => @port.to_i
    end

    sleep 0.1 until alive?
  end
  
  def find_free_port
    @port += 1 while alive?
  end
  
  def alive?
    s = TCPSocket.new( @host, @port )
    s.close
    s
  rescue Errno::ECONNREFUSED
    false 
  end

  def get_response(action)
    res = Net::HTTP.start(self.host, self.port) do |http|
      http.get(action)
    end
  end
  
  def delete_response(action, data = "", headers = nil, dest = nil)
    data = data.empty? ? "_method=delete" : data += "&_method=delete"
    post_response(action, data, headers, dest)
  end
  
  def put_response(action, data = "", headers = nil, dest = nil)
    data = data.empty? ? "_method=put" : data += "&_method=put"
    post_response(action, data, headers, dest)
  end
  
  def post_response(action, data, headers = nil, dest = nil)
    res = Net::HTTP.start(self.host, self.port) do |http|
      http.post(action, data, headers, dest)
    end
  end
  
  def method_missing(method, *args, &block)
    SinatraStem.instance_eval do |base|
      route method.to_s.upcase, *args, &block
    end 
  end

end
