##
# monitoring beacon logs buffer.
class BeaconLog
  LOG_LIFE_INTERVAL = 2
  CLOSED_DISTANCE = 1.2 # [m]

  def initialize
    @mutex = Mutex.new
    clear
    @th = Thread.new do
      loop do
        sleep(LOG_LIFE_INTERVAL)
        remove_old_logs
      end
    end
  end

  ##
  # clear all logs
  def clear
    @mutex.synchronize do
      @logs = Hash.new { |h, k| h[k] = [] }
    end
  end

  ##
  # add new log
  # @param log new log
  def add(log)
    @mutex.synchronize do
      log[:tick] = Time.now
      beacon = %i[major minor].each.with_object({}) { |s, o| o[s] = log[s] }
      @logs[beacon].push log
    end
  end

  ##
  # make closed beacons array.
  # @return closed_beacons [{:major, :minor}, ...]
  def closed_beacons
    @mutex.synchronize do
      @logs.each.with_object([]) do |(beacon, log), o|
        o.push beacon if near?(log)
      end
    end
  end

  private def near?(log)
    return false if log.size < 5
    a = log.map { |m| m[:accuracy] }
    median(a) < CLOSED_DISTANCE
  end

  private def median(ary)
    ary.sort!
    i = ary.size / 2
    ary.size.odd? ? ary[i] : (ary[i - 1] + ary[i]) / 2
  end

  private def remove_old_logs
    @mutex.synchronize do
      now = Time.now
      @logs.each_key do |beacon|
        log = @logs[beacon]
        log.shift until log.empty? || now - log.first[:tick] < LOG_LIFE_INTERVAL
        @logs.delete beacon if log.empty?
      end
    end
  end
end

if $0 == __FILE__
  Thread.abort_on_exception = true # exit process if except in thread
  logs = BeaconLog.new
  Thread.new do
    loop do
      log = { uuid: 'b9407f30f5f8466eaff925556b57fe6d', major: 36, minor: 5, measuredPower: -57, rssi: -34, proximity: 'immediate' }
      log[:accuracy] = rand(200) / 100.0
      logs.add log
      sleep(0.1)
    end
  end
  loop do
    p logs.closed_beacons
    sleep(1)
  end
end
