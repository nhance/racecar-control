require 'socket'

class RaceMonitorServer
  LISTEN_ADDR = '0.0.0.0'
  PORT = 50002

  def initialize
    @socket = TCPServer.new(LISTEN_ADDR, PORT)
  end

  def method_missing(*args)
    name = args.shift
    @socket.send(name, args)
  end

  def accept
    puts "Listening on #{LISTEN_ADDR}:#{PORT} for Race Monitor Relay connection"
    puts "If developing, connect to this to see what Race Monitor Relay sees"
    @socket.accept
  end

  def write(message)
    @socket.write(message.to_s)
  end

  def close
    if @socket && !@socket.closed?
      @socket.close
    end
  end
end
