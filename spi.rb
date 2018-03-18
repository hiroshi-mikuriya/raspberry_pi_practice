require'./bcm2835'

loop do
  tx = %w[2 0 0 55 AA].map(&:hex).pack('c*')
  SPI.write(tx, SPI::CS0)
  sleep(1)
end
