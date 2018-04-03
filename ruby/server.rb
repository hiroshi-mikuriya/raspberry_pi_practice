require 'socket'
require 'json'

##
# Server thread
class Server
  ##
  # Waiting for receiving udp packet from positioning server.
  private def polling_udp(udp, id, lcd, led)
    d = udp.recv(65_535) # wait for receiving
    v = JSON.parse(d)[id]
    led[:mutex].synchronize do
      unless v == led[:v]
        led[:v] = v
        led[:modified] = true
        lcd[:modified] = true
      end
    end
  rescue => e
    puts e
  end

  ##
  # @param id Selfball ID
  # @param lcd { modified: false }
  # @param led { modified: true, mutex: Mutex.new, v: [] }
  def initialize(id, lcd, led)
    udp = UDPSocket.open
    udp.bind('0.0.0.0', 4000)
    puts %(UDP socket is opened.)
    loop { polling_udp(udp, id, lcd, led) }
  rescue => e
    puts e
  end
end
