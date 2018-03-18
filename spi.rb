require 'spi'
s = SPI.new(device: '/dev/spidev32766.0')
s.speed = 500_000
s.xfer(txdata: [0x10, 0x00])
