require 'socket'
require 'json'

sock = TCPSocket.open('192.168.2.42', 4000)
sock.write({ favorite: 0xFFFF }.to_json)
sock.close
