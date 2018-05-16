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

if $PROGRAM_NAME == __FILE__
  uuid = 'B9407F30-F5F8-466E-AFF9-25556B57FE6D'.delete('-').downcase.freeze # TODO: mod other uuid
  id = 6
  logs = BeaconLog.new
  BeaconConst.new(uuid, id, logs)
end
