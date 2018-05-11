require 'open3'
require 'json'
require './beacon_log'

##
# Monitoring and Advertising beacon rssi
class BeaconConst
  ##
  # @param uuid Beacon filtering uuid
  # @param id selfball ID
  # @param beacon_logs [BeaconLog]
  def initialize(uuid, id, beacon_logs)
    loop do
      cmd = { proc: 'node', file: 'beacon.js', uuid: uuid, major: id, minor: 0, measure: -59 }.freeze
      Open3.popen3(cmd.values.join(' ')) do |_i, o, _e, _w|
        o.each { |log| beacon_logs.add(JSON.parse(log, symbolize_names: true)) }
      end
    end
  end
end
