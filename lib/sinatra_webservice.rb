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
    @port = options[:port] ? options[:port].to_i : 4567
  end
  
  def running?
    self.current_thread.alive? rescue false
  end

  def run!
    find_free_port
    
    self.current_thread = Thread.new do
      SinatraStem.run! :post => @host, :port => @port
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

  def method_missing(method, *args, &block)
    SinatraStem.instance_eval do |base|
      route method.to_s.upcase, *args, &block
    end 
  end

end
