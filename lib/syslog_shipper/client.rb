require "socket"

module SyslogShipper
  class Client < EventMachine::FileTail
    def initialize path, options = {:startpos => -1}
      super path, options[:startpos]
      @buffer = BufferedTokenizer.new
      @hostname = Socket.gethostname
      @connector = options[:connector]
      @connection = @connector.call()
      @raw = options[:raw]
      @ping = options[:ping]
      @verbose = options[:verbose]
  
      if options[:mark] > 0
          EM.add_periodic_timer( options[:mark] ) do
            send_data("ping pong\n")
          end
      end
    end

    def receive_data(data)
      @buffer.extract(data).each do |line|
        if @ping
          puts 'connection successful'
          exit
        end
        
        if message = build_message(line)
          puts message if @verbose
          send_data message
        end
      end 
    end

    private

    def send_data line
      if(@connection.error?)
	@connection = @connector.call()
      end
      @connection.send_data line        
    end

    def build_message line
      # don't send anything if there is no data
      return if line && line.gsub(/\s/, '').empty?

      if @raw
        "#{line}\n"
      else
        "#{Time.now.strftime("%b %d %H:%M:%S")} #{@hostname} #{path}: #{line}\n"
      end
    end
  end
end
