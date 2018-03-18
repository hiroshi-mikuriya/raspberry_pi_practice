require 'pi_piper'

RESOLUTION_AT_12BIT = 0b111111111111.to_f.freeze

PiPiper::Spi.begin do |spi|
  loop do
    _, center, last = spi.write [0b00000110, 0b00000000, 0b00000000]
    center &= 0b00001111
    center = center << 8
    value =  center + last
    percentage = value / RESOLUTION_AT_12BIT * 100
    puts "#{percentage} %"
    sleep 0.1
  end
end
