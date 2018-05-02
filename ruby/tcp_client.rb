require 'socket'
require 'json'

sock = TCPSocket.open('169.254.205.61', 4001)
sock.write({ colors: %w[aqua yellow green], interval: 10 }.to_json)
sock.close
