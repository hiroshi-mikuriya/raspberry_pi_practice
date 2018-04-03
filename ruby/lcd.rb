require './bcm2835'
require './raw'

##
# LCD thread
class Lcd
  ##
  # @param lcd { modified: true }
  def initialize(lcd)
    proc(lcd)
  rescue => e
    puts e
  end

  private def proc(lcd)
    RAWS.each do |ix, raw|
      raise 'invalid raw length.' unless raw.size == RAW_SIZE
      addr = ix * RAW_SIZE
      write(addr, raw, SPI::CS1)
    end
    write(1, (OPEN << 4) + OPEN, SPI::CS0)
    last_blink_time = Time.now
    loop do
      sleep(0.01)
      now = Time.now
      next unless now - last_blink_time > 3 || lcd[:modified]
      lcd[:modified] = false
      write(1, (CLOSE << 4) + CLOSE, SPI::CS0)
      sleep(0.1)
      write(1, (OPEN << 4) + OPEN, SPI::CS0)
      last_blink_time = now
    end
  end

  private def write(addr, data, cs)
    pkt = [2, [addr].pack('n*').unpack('C*'), data].flatten.pack('C*')
    SPI.write(pkt, cs)
  end
end
