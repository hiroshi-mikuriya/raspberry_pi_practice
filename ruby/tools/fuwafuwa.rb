require './bcm2835'

if BCM.bcm2835_init.zero?
  puts 'failed to init bcm2835.'
  exit 1
end

SPI.write(packet('clear'), SPI::CS0) # clear all

ARGV.each do |color|
  begin_time = Time.now
  loop do
    t = Time.now - begin_time
    break if t > 2
    pow = [(Math.sin(t * Math::PI) * 128) + 128, 255].min
    SPI.write(packet(color, pow), SPI::CS0)
  end
end

##
# Make packet for lighting led.
def packet(color_name, pow)
  case color_name.downcase
  when 'red' then rgb(r: pow)
  when 'blue' then rgb(b: pow)
  when 'green' then rgb(g: pow)
  when 'yellow' then rgb(r: pow, g: pow)
  when 'aqua' then rgb(g: pow, b: pow)
  when 'pink' then rgb(b: pow, r: pow)
  else rgb(brightness: 8)
  end
end

##
# make rgb packet
# @param pow { b: 0, g: 0, r: 0, brightness: 1 }
def rgb(pow)
  r, g, b = %i[r g b].map { |s| pow[s] || 0 }.map(&:to_i)
  brightness = pow[:brightness] || 2
  brightness = [4, brightness].min unless [r, g, b].all?(&:zero?) # limitter(fool proof)
  [2, [0x1000].pack('n*').unpack('C*'), [r, g, b] * 32 * brightness].flatten.pack('c*')
end
