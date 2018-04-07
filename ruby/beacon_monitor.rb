require 'open3'
require 'json'
require 'thread'

##
# Monitoring beacon rssi
class BeaconMonitor
  ##
  # @param rssi
  # @param lcd
  # @param led
  def monitor_beacon(rssi, lcd, led)
    js = JSON.parse(rssi, symbolize_names: true)
    if js[:rssi] < -45 && @near
      puts "[#{Time.now}] beacon absence"
      @near = false
      led[:mutex].synchronize do
        led[:v] = []
        led[:modified] = true
      end
    end
    return unless js[:rssi] > -35 && !@near
    puts "[#{Time.now}] beacon presence"
    @near = true
    led[:mutex].synchronize do
      led[:v] = %w[red green blue yellow aqua pink]
      led[:modified] = true
      lcd[:modified] = true
    end
  end

  ##
  # kill process if modified favorite.
  def monitor_process(pid, favorite)
    loop do
      sleep(1)
      if favorite[:modified]
        favorite[:modified] = false
        Process.kill('KILL', pid)
        return
      end
    end
  end

  ##
  # @param uuid Beacon filtering uuid
  # @param favorite { modified: boolean, v: id }
  # @param lcd { modified: false }
  # @param led { modified: true, mutex: Mutex.new, v: [] }
  def initialize(uuid, favorite, lcd, led)
    loop do
      @near = false
      cmd = ['node', 'beacon.js', uuid, id, favorite[:v], -59].join(' ')
      Open3.popen3(cmd) do |_i, o, _e, w|
        puts "start beacon. PID: #{w.pid}"
        th = Thread.new { monitor_process(w.pid, favorite) }
        o.each { |rssi| monitor_beacon rssi }
        th.join
        puts 'end beacon.'
      end
    end
  end
end
