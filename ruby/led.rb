require './bcm2835'

##
# LED thread
class Led
  ##
  # @param led { modified: true, mutex: Mutex.new, v: [] }
  def initialize(led)
    SPI.write([2, 0, 4, 0].pack('C*'), SPI::CS0) # stop demo
    color = ColorSelector.new(led)
    SPI.write(color.get, SPI::CS0) # Clear all
    loop do
      SPI.write(color.get, SPI::CS0)
      sleep(0.01)
    end
  rescue => e
    puts e
  end

  ##
  # Make optimal rgb packet according to time.
  class ColorSelector
    UNIT_COLOR_INTERVAL = 10 # [sec]
    BRIGHTNESS = 2 # [1...8]

    def initialize(led)
      @led = led
    end

    ##
    # Update fields if led modified
    def update_if_modified
      return unless @led[:modified]
      @led[:mutex].synchronize do
        @led[:modified] = false
        @colors = @led[:v]
        SPI.write([2, 0, 2, 3, 10].pack('C*'), SPI::CS0) unless @colors.empty?
      end
      @begin_time = Time.now
    end

    ##
    # Get packet for displaying current color.
    def get
      update_if_modified
      interval = Time.now - @begin_time
      pow = (1 + Math.sin(interval * Math::PI)) * 128
      pow = [pow, 255].min
      make_packet(current_color_name(interval), pow)
    end

    ##
    # Make packet for lighting led.
    private def make_packet(color_name, pow)
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
    # Get current color name.
    # @param interval Time.now - @begin_time
    private def current_color_name(interval)
      return 'clear' if @colors.empty?
      i = (interval / UNIT_COLOR_INTERVAL).to_i % @colors.size
      @colors[i]
    end

    ##
    # make rgb packet
    # @param pow { b: 0, g: 0, r: 0, brightness: 1 }
    private def rgb(pow)
      r, g, b = %i[r g b].map { |s| pow[s] || 0 }.map(&:to_i)
      brightness = pow[:brightness] || BRIGHTNESS
      brightness = [4, brightness].min unless [r, g, b].all?(&:zero?) # limitter(fool proof)
      [2, [0x1000].pack('n*').unpack('C*'), [r, g, b] * 32 * brightness].flatten.pack('c*')
    end
  end
end
