require 'json'
require 'httpclient'

##
# Report closed beacons to God.
class Reporter
  TIME_LIMIT = 2 # [sec]

  ##
  # @param beacon_logs { v: { beacon: [:time, :accuracy] }, mutex: Mutex }
  # @param lcd { modified: false, error: false }
  def initialize(beacon_logs, lcd)
    loop do
      beacons = []
      beacon_logs[:mutex].synchronize do
        remove_old_data beacon_logs[:v]
        beacon_logs[:v].each do |beacon, logs|
          beacons.push beacon if logs.size > 5
        end
      end
      begin
        send_report(beacons)
        lcd[:error] = false
      rescue
        lcd[:error] = true
      end
      sleep(1)
    end
  end

  ##
  # @param beacons { beacon: [:time, :accuracy] }
  def remove_old_data(beacons)
    now = Time.now
    beacons.keys.each do |beacon|
      logs = beacons[beacon] # [Log, Log, ...]
      loop do
        if logs.empty?
          beacons.delete(beacon)
          break
        end
        log = logs.first
        break if now - log[:time] < TIME_LIMIT
        logs.shift
      end
    end
  end

  ##
  # send closed beacons to God
  def send_report(data)
    # p({ beacons: data }.to_json)
  end
end

if $0 == __FILE__
  default_logs = Hash.new { |h, k| h[k] = [] }
  beacon_logs = Struct.new(:v, :mutex).new(default_logs, Mutex.new)
  lcd = Struct.new(:modified, :error).new(false, false)
  Reporter.new(beacon_logs, lcd)
end
