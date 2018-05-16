# frozen_string_literal: true

require 'socket'
require 'json'
require './favorite'

##
# Server is prompted for favorite from favorite server.
class ServerFavorite
  ##
  # @param favorite (:modified)
  def initialize(favorite)
    loop { implementation(favorite) }
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
  # @param favorite (:modified)
  private def implementation(favorite)
    pkt = tcp_server(4001)
    v = JSON.parse(pkt, symbolize_names: true)
    return unless v.key? :favorite
    Favorite.write(v[:favorite].to_i)
    favorite[:modified] = true
  rescue StandardError => e
    puts e
  end
end
