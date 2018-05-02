require 'socket'
require 'json'

##
# Server thread
class Server
  ##
  # @param led {:modified, :mutex, :colors, :interval}
  # @param lcd {:modified, :error}
  def initialize(led, lcd)
    loop { impl(led, lcd) }
  end

  ##
  # @param led {:modified, :mutex, :colors, :interval}
  # @param lcd {:modified, :error}
  private def impl(led, lcd)
    s0 = TCPServer.open(4001)
    puts %(TCP socket is opened.)
    socket = s0.accept
    d = socket.gets # wait for receiving
    puts d
    v = JSON.parse(d, symbolize_names: true)
    led[:mutex].synchronize do
      lcd[:modified] = true unless lcd[:error]
      %i[colors interval].each { |s| led[s] = v[s] }
    end
  rescue => e
    puts e
  ensure
    socket.close
    s0.close
  end
end
