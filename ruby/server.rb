require 'socket'
require 'json'

##
# Server thread
class Server
  ##
  # 
  def impl(favorite)
    s0 = TCPServer.open(4000)
    socket = s0.accept
    puts %(TCP socket is opened.)
    d = socket.gets # wait for receiving
    puts d
    v = JSON.parse(d, symbolize_names: true)
    if favorite[:v] != v[:favorite]
      favorite[:v] = v[:favorite] # TODO: archive favorite (JSON file)
      favorite[:modified] = true
    end
  rescue => e
    puts e
  ensure
    socket.close
    s0.close
  end

  ##
  # @param favorite { modified: boolean, v: id }
  def initialize(favorite)
    loop { impl(favorite) }
  end
end
