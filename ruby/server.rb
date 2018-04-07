require 'socket'
require 'json'

##
# Server thread
class Server
  ##
  # Waiting for receiving udp packet from positioning server.
  private def polling_udp(favorite, udp)
    d = udp.recv(65_535) # wait for receiving
    v = JSON.parse(d, symbolize_names: true)
    if v[:favorite] != favorite[:v]
      favorite[:v] = v[:favorite] # TODO: archive favorite (JSON file)
      favorite[:modified] = true
    end
  rescue => e
    puts e
  end

  ##
  # @param favorite { modified: boolean, v: id }
  def initialize(favorite)
    udp = UDPSocket.open # TODO: tcp
    udp.bind('0.0.0.0', 4000)
    puts %(UDP socket is opened.)
    loop { polling_udp(favorite, udp) }
  rescue => e
    puts e
  end
end
