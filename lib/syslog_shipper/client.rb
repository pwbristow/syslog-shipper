#!/usr/bin/env ruby

# http://andyjeffries.co.uk/articles/x509-encrypted-authenticated-socket-ruby-client
# require 'socket'
# require 'openssl'
# 
# socket = TCPSocket.new('my.secure.service', 443)
# socket.puts("GET / HTTP/1.0")
# socket.puts("")
# 
# while line = socket.gets
#   p line
# end

# 
# socket = TCPSocket.new('my.secure.service', 443)
# ssl_context = OpenSSL::SSL::SSLContext.new()
# ssl_socket = OpenSSL::SSL::SSLSocket.new(socket, ssl_context)
# ssl_socket.sync_close = true
# ssl_socket.connect
# 
# ssl_socket.puts("GET / HTTP/1.0")
# ssl_socket.puts("")
# 
# while line = ssl_socket.gets
#   p line
# end

require "socket"

class Client < EventMachine::FileTail
  def initialize(path, startpos=-1, connection=nil, raw=false, verbose=false)
    super(path, startpos)
    @buffer = BufferedTokenizer.new
    @hostname = Socket.gethostname
    @connection = connection
    @raw = raw
    @verbose = verbose
  end

  def receive_data(data)
    @buffer.extract(data).each do |line|
      if @raw
        @connection.send_data("#{line}\n")
        puts line if @verbose
      else
        timestamp = Time.now.strftime("%b %d %H:%M:%S")
        syslogline = "#{timestamp} #{@hostname} #{path}: #{line}\n"
        print syslogline if @verbose
        @connection.send_data(syslogline)
      end
    end # buffer extract
  end # def receive_data
end # class Shipper