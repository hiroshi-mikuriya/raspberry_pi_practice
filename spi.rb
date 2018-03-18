require './bcm2835'

WRITE = 0x02
ADDR = [0, 0].freeze
CLEAR = [WRITE, ADDR, [0] * 96 * 8].flatten.pack('c*').freeze
WHITE = [WRITE, ADDR, [0xFF] * 96].flatten.pack('c*').freeze
BLUE = [WRITE, ADDR, ([0xFF] * 4 + [0] * 8) * 8].flatten.pack('c*').freeze
GREEN = [WRITE, ADDR, ([0] * 4 + [0xFF] * 4 + [0] * 4) * 8].flatten.pack('c*').freeze
RED = [WRITE, ADDR, ([0] * 8 + [0xFF] * 4) * 8].flatten.pack('c*').freeze

loop do
  [CLEAR, WHITE, BLUE, GREEN, RED].each do |color|
    SPI.write(color, SPI::CS0)
    sleep(1)
  end
end
