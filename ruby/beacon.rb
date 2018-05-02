require 'open3'
require 'json'

##
# Monitoring and Advertising beacon rssi
class Beacon
  Log = Struct.new(:time, :accuracy)

  ##
  # @param rssi
  def monitor_beacon(rssi, beacon_logs)
    js = JSON.parse(rssi, symbolize_names: true)
    # js = { uuid: 'b9407f30f5f8466eaff925556b57fe6d', major: 36, minor: 5,
    # measuredPower: -57, rssi: -34, accuracy: 0.22223443385817412, proximity: 'immediate' }
    return if js[:accuracy] > 2
    beacon = js[:major]
    beacon_logs[:mutex].synchronize do
      beacon_logs[:v][beacon].push Log.new(Time.now, js[:accuracy].to_f)
    end
  end

  ##
  # @param uuid Beacon filtering uuid
  # @param id selfball ID
  # @param beacon_logs
  def initialize(uuid, id, beacon_logs)
    loop do
      cmd = { proc: 'node', file: 'beacon.js', uuid: uuid, major: id, minor: 0, measure: -40 }.freeze
      Open3.popen3(cmd.values.join(' ')) do |_i, o, _e, _w|
        o.each { |rssi| monitor_beacon(rssi, beacon_logs) }
      end
    end
  end
end
