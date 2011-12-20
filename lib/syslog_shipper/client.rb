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
  def initialize(path, startpos=-1, raw=false, verbose=false)
    super(path, startpos)
    @buffer = BufferedTokenizer.new
    @hostname = Socket.gethostname
    @raw = raw
    @verbose = verbose

    setup_intermediary
  end

  def receive_data(data)
    @buffer.extract(data).each do |line|
      line = if @raw
        "#{line}\n"
      else
        timestamp = Time.now.strftime("%b %d %H:%M:%S")
        "#{timestamp} #{@hostname} #{path}: #{line}\n"
      end

      print line if @verbose
      send_data(line)
    end 
  end

  private

  def send_data line
    @pseudo_client.send line, 0
  end

  def setup_intermediary
    puts "setting up"
    @pseudo_client, @pseudo_server = Socket.pair(:UNIX, :DGRAM, 0)
    Process.fork do 
      i = 0
      Socket.udp_server_loop_on([@pseudo_server]) do |msg, msg_src|
        puts msg
        puts msg_src
        puts "done #{i}"
        i += 1
      end
    end

    puts "done setting up"
  end
end