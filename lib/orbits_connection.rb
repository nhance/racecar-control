require 'socket'

class OrbitsConnection
  def self.connect(ip, port = 50000)
    orbits = new
    orbits.connect(ip, port)

    orbits
  end

  def initialize
    @socket = nil
  end

  def connect(ip, port = 50000)
    @socket = TCPSocket.new(ip, port)
  end

  def gets
    @socket.gets
  end

  def get_scoreboard_message
    ScoreboardMessage.parse(gets)
  end

  def closed?
    @socket.closed?
  end

  def close
    if @socket.present? && !closed?
      @socket.close
    end
  end
end
