require 'open3'
require 'json'

##
# Monitoring beacon rssi
class BeaconMonitor
  ##
  # @param uuid Beacon filtering uuid
  # @param lcd { modified: false }
  # @param led { modified: true, mutex: Mutex.new, v: [] }
  def initialize(uuid, lcd, led)
    near = false
    Open3.popen3("node monitor.js #{uuid}") do |_i, o, _e|
      o.each do |d|
        js = JSON.parse(d, symbolize_names: true)
        if js[:rssi] < -45 && near
          puts "[#{Time.now}] beacon absence"
          near = false
          led[:mutex].synchronize do
            led[:v] = []
            led[:modified] = true
          end
        end
        next unless js[:rssi] > -35 && !near
        puts "[#{Time.now}] beacon presence"
        near = true
        led[:mutex].synchronize do
          led[:v] = %w[red green blue yellow aqua pink]
          led[:modified] = true
          lcd[:modified] = true
        end
      end
    end
  end
end
