require 'socket'
require 'json'

##
# Server is prompted for LED instruction from God.
class ServerLed
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
    TCPServer.open(4001) do |s0|
      puts %(TCP socket is opened.)
      socket = s0.accept
      d = socket.gets # wait for receiving
      puts d
      v = JSON.parse(d, symbolize_names: true)
      led[:mutex].synchronize do
        lcd[:modified] = true unless lcd[:error]
        %i[colors interval].each { |s| led[s] = v[s] }
      end
      socket.close
    end
  rescue StandardError => e
    puts e
  end
end
