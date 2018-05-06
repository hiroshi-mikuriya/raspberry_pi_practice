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
      loop_inner_proc(id, beacon_logs, lcd)
      sleep(1)
    end
  end

  ##
  # called by Reporter.initialize
  # @param id my selfball id
  # @param beacon_logs { v: { beacon: [:time, :accuracy] }, mutex: Mutex }
  # @param lcd { modified: false, error: false }
  private def loop_inner_proc(id, beacon_logs, lcd)
    beacons = closed_beacons(beacon_logs)
    send_report(me: id, friends: beacons)
    lcd[:error] = false
  rescue
    lcd[:error] = true
  end

  ##
  # get closed beacons from beacon logs.
  # @param beacon_logs
  private def closed_beacons(beacon_logs)
    beacon_logs[:mutex].synchronize do
      remove_old_data beacon_logs[:v]
      return beacon_logs[:v].each.with_object([]) do |(beacon, logs), o|
        o.push beacon if logs.size > 5
      end
    end
  end

  ##
  # @param beacons { beacon: [:time, :accuracy] }
  private def remove_old_data(beacons)
    now = Time.now
    beacons.each_key do |_, logs|
      logs.shift until logs.empty? || now - logs.first[:time] < TIME_LIMIT
    end
  end

  ##
  # send closed beacons to God
  private def send_report(data)
    HTTPClient.new do |c|
      c.connect_timeout = 5
      c.send_timeout = 5
      c.receive_timeout = 5
      c.post('http://192.168.11.2:4567/report', data)
    end
  end
end

if $0 == __FILE__
  default_logs = Hash.new { |h, k| h[k] = [] }
  beacon_logs = Struct.new(:v, :mutex).new(default_logs, Mutex.new)
  lcd = Struct.new(:modified, :error).new(false, false)
  id = 6
  Reporter.new(id, beacon_logs, lcd)
end
