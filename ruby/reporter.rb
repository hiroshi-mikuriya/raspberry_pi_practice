require 'httpclient'
require 'json'
require './beacon_log'

##
# Report closed beacons to God.
class Reporter
  ##
  # @param id my selfball id
  # @param beacon_logs [BeaconLog]
  # @param lcd { modified: false, error: false }
  def initialize(id, beacon_logs, lcd)
    loop do
      loop_inner_proc(id, beacon_logs, lcd)
      sleep(1)
    end
  end

  ##
  # called by Reporter.initialize
  # @param id my selfball id
  # @param beacon_logs [BeaconLog]
  # @param lcd { modified: false, error: false }
  private def loop_inner_proc(id, beacon_logs, lcd)
    beacons = beacon_logs.closed_beacons.map { |m| m[:major] }
    send_report(me: id, friends: beacons)
    lcd[:error] = false
  rescue StandardError
    lcd[:error] = true
  end

  ##
  # send closed beacons to God
  private def send_report(data)
    uri = 'http://192.168.11.2:4567/report'.freeze
    HTTPClient.new do |c|
      c.connect_timeout = 10
      c.send_timeout = 10
      c.receive_timeout = 10
      c.post_content(uri, data.to_json, 'content-type' => 'application/json')
    end
  end
end

if $0 == __FILE__
  Thread.abort_on_exception = true # exit process if except in thread
  logs = BeaconLog.new
  lcd = Struct.new(:modified, :error).new(false, false)
  id = 6
  Thread.new do
    loop do
      log = { uuid: 'b9407f30f5f8466eaff925556b57fe6d', major: 36, minor: 5, measuredPower: -57, rssi: -34, proximity: 'immediate' }
      log[:accuracy] = rand(256) / 100.0
      logs.add log
      sleep(0.1)
    end
  end
  Reporter.new(id, logs, lcd)
end
