# frozen_string_literal: true

require 'socket'
require 'json'

##
# Server is prompted for LED instruction from God.
class ServerLed
  ##
  # @param led {:modified, :mutex, :colors, :interval}
  # @param lcd {:modified, :error}
  def initialize(led, lcd)
    loop { implementation(led, lcd) }
  end

  private def tcp_server(port)
    TCPServer.open(port) do |s0|
      puts %(TCP socket is opened.)
      socket = s0.accept
      d = socket.gets
      socket.close
      d
    end
  end

  ##
  # @param led {:modified, :mutex, :colors, :interval}
  # @param lcd {:modified, :error}
  private def implementation(led, lcd)
    d = tcp_server(4001)
    v = JSON.parse(d, symbolize_names: true)
    expects = %i[colors interval].freeze
    return unless expects.all? { |s| v.key? s }
    led[:mutex].synchronize do
      lcd[:modified] = true unless lcd[:error]
      expects.each { |s| led[s] = v[s] }
    end
  rescue StandardError => e
    puts e
  end
end
