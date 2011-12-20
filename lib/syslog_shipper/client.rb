require "socket"
require 'openssl'

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
    @pseudo_client, @pseudo_server = Socket.pair(:UNIX, :DGRAM, 0)
    Process.fork do 
      socket = TCPSocket.new('logs.loggly.com', 32018)
      ssl_context = OpenSSL::SSL::SSLContext.new()
      # ssl_context.post_connection_check('logs.loggly.com')

      ssl_socket = OpenSSL::SSL::SSLSocket.new(socket, ssl_context)
      ssl_socket.sync_close = true
      ssl_socket.connect

      i = 0
      Socket.udp_server_loop_on([@pseudo_server]) do |msg, msg_src|
        ssl_socket.puts msg
        i += 1
        puts i
      end
    end
  end
end