require './bcm2835'

##
# LED thread
class Led
  ##
  # @param led (:mutex, :colors, :interval)
  def initialize(led)
    stop_demo
    stop_sleep_timer
    clear_led
    loop do
      if led[:colors].empty?
        sleep(1)
        next
      end
      colors = []
      interval = 0
      led[:mutex].synchronize do
        colors = led[:colors]
        interval = led[:interval]
        led[:colors] = []
        led[:interval] = 0
      end
      flash_led(colors, interval)
      clear_led
    end
  rescue StandardError => e
    puts e
  end

  private def stop_demo
    SPI.write([2, 0, 4, 0].pack('C*'), SPI::CS0)
  end

  private def stop_sleep_timer
    SPI.write([2, 0, 6, 0].pack('C*'), SPI::CS0)
  end

  private def clear_led
    SPI.write([2, [0x1000].pack('n*').unpack('C*'), [0] * 3 * 32 * 8].flatten.pack('c*'), SPI::CS0)
  end

  private def flash_led(colors, interval)
    begin_time = Time.now
    colors = (colors * 16).take(16)
    loop do
      t = Time.now - begin_time
      break if t >= interval
      pow = (-Math.cos(t * Math::PI) + 1) / 2 * 255
      SPI.write(packet(colors, pow), SPI::CS0)
      sleep(0.02)
    end
  end

  private def rgb(name, pow)
    case name
    when 'red' then [pow, 0, 0]
    when 'green' then [0, pow, 0]
    when 'blue' then [0, 0, pow]
    when 'yellow' then [pow, pow * 0.6, 0]
    when 'aqua' then [0, pow, pow]
    when 'pink' then [pow, 0, pow]
    when 'white' then [pow, pow, pow]
    else [0, 0, 0]
    end
  end

  private def packet(colors, pow)
    a = colors.map { |name| rgb(name, pow) }
    brightness = 2
    [2, [0x1000].pack('n*').unpack('C*'), a * 2 * brightness].flatten.pack('c*')
  end
end

if $PROGRAM_NAME == __FILE__
  if BCM.bcm2835_init.zero?
    puts 'failed to init bcm2835.'
    exit 1
  end
  led = Struct.new(:modified, :mutex, :colors, :interval).new(true, Mutex.new, %w[red green], 10)
  Led.new(led)
end
