require './bcm2835'

if BCM.bcm2835_init.zero?
  puts 'failed to init bcm2835.'
  exit 1
end

def rgb(name, pow)
  case name
  when 'red' then [pow, 0, 0]
  when 'green' then [0, pow, 0]
  when 'blue' then [0, 0, pow]
  when 'yellow' then [pow, pow, 0]
  when 'aqua' then [0, pow, pow]
  when 'pink' then [pow, 0, pow]
  when 'white' then [pow, pow, pow]
  else [0, 0, 0]
  end
end

def packet(colors, pow)
  a = colors.map { |name| rgb(name, pow) }
  # [2, [0x1000].pack('n*').unpack('C*'), [r, g, b] * 32 * brightness].flatten.pack('c*')
  brightness = 2
  [2, [0x1000].pack('n*').unpack('C*'), a * 2 * brightness].flatten.pack('c*')
end
SPI.write(packet(['clear'] * 16, 8), SPI::CS0) # clear all

colors = ARGV.to_a
p colors = Array.new(16) { |i| colors[colors.size * i / 16] }

begin_time = Time.now
loop do
  t = Time.now - begin_time
  break if t >= 10
  pow = [(Math.sin(t * Math::PI) * 128) + 128, 255].min
  SPI.write(packet(colors, pow), SPI::CS0)
end
