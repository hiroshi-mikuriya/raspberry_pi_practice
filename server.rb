require 'socket'
require 'json'

PORT = 4_000
udps = UDPSocket.open
udps.bind('0.0.0.0', PORT)
loop do
  data = udps.recv(65_535)
  JSON.parse(data, symbolize_names: true).each do |ball, colors|
    puts %(#{ball} : #{colors})
  end
end
udps.close
