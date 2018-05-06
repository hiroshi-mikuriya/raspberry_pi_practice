require 'httpclient'

##
# Report closed beacons to God.
class Reporter
  TIME_LIMIT = 2 # [sec]

  ##
  # @param id my selfball id
  # @param beacon_logs { v: { beacon: [:time, :accuracy] }, mutex: Mutex }
  # @param lcd { modified: false, error: false }
  def initialize(id, beacon_logs, lcd)
    loop do
      begin
        beacons = closed_beacons(beacon_logs)
        send_report(me: id, friends: beacons)
        lcd[:error] = false
      rescue => e
        puts e
        lcd[:error] = true
      end
      sleep(1)
    end
  end

  ##
  # get closed beacons from beacon logs.
  # @param beacon_logs
  private def closed_beacons(beacon_logs)
    beacons = []
    beacon_logs[:mutex].synchronize do
      remove_old_data beacon_logs[:v]
      beacon_logs[:v].each do |beacon, logs|
        beacons.push beacon if logs.size > 5
      end
    end
    beacons
  end

  ##
  # @param beacons { beacon: [:time, :accuracy] }
  private def remove_old_data(beacons)
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
  private def send_report(data)
    client = HTTPClient.new
    res = client.post('http://192.168.11.2:4567/closed_beacons', data)
    p res
  end
end

if $0 == __FILE__
  default_logs = Hash.new { |h, k| h[k] = [] }
  beacon_logs = Struct.new(:v, :mutex).new(default_logs, Mutex.new)
  lcd = Struct.new(:modified, :error).new(false, false)
  id = 6
  Reporter.new(id, beacon_logs, lcd)
end
