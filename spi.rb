require './bcm2835'

loop do
  tx = %w[2 0 0 55 AA].map(&:hex).pack('c*')
  rx = SPI.read_write(tx, SPI::CS0)
  puts tx == rx ? 'matched !' : 'unmatched !'
  sleep(1)
end
