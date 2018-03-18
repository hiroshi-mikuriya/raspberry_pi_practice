require 'bcm2835'

SPI.begin do |spi|
  spi.write(0x22, 0x45, 0x71)
end
