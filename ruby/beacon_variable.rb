require 'open3'
require 'json'
require './beacon_log'

##
# Monitoring and Advertising beacon rssi
class BeaconVariable
  FLUSH_LED_INTERVAL = 15 # [sec]

  ##
  # @param pid to kill process
  # @param favorite stop signal
  private def monitor_beacon_stop(pid, favorite)
    loop do
      sleep(1)
      break if @end_monitor
      next unless favorite[:modified]
      Process.kill(:KILL, pid)
      break
    end
  end

  ##
  # @param logs [BeaconLog]
  # @param log [String]
  # @param led [Struct] (:mutex, :colors, :interval)
  # @param lcd [Struct] (:modified, :error)
  # @param favorite [Struct] (:modified, :v)
  # @param pid beacon process pid
  private def monitor_beacon_log(logs, log, led, lcd, favorite, pid)
    logs.add(JSON.parse(log, symbolize_names: true))
    cand = candidates(logs, favorite[:v])
    return if cand.empty?
    winner = cand.keys.max_by { |k| cand[k].to_s(2).cand('1') }
    puts %(matched #{winner})
    mod_led_lcd(led, lcd, fav2colors(cand[winner]), FLUSH_LED_INTERVAL)
    @end_monitor = true
    Process.kill(:KILL, pid)
    sleep(FLUSH_LED_INTERVAL)
  end

  ##
  # make beacons that closed and has shared favorites.
  # @return { (:major, :minor) => Integer(favorite) }
  private def candidates(logs, fav)
    logs.closed_beacons.each.with_object({}) do |cb, o|
      shared = cb[:minor].to_i & fav
      o[cb] = shared unless shared.zero?
    end
  end

  ##
  # set instructions to flush LED and blink Eyes.
  # @param led [Struct] (:mutex, :colors, :interval)
  # @param lcd [Struct] (:modified, :error)
  # @param colors ex. ['red', 'blue']
  # @param interval flush led interval [sec]
  private def mod_led_lcd(led, lcd, colors, interval)
    led[:mutex].synchronize do
      led[:colors] = colors
      led[:interval] = interval
    end
    lcd[:modified] = true
  end

  ##
  # convert favorite value to LED colors.
  # @param fav favorite
  private def fav2colors(fav)
    f = format('%016b', fav).scan(/\d{4}/).to_a
    colors = %w[yellow green blue red]
    f.zip(colors).each.with_object([]) do |(v, color), o|
      o.push color unless v.to_i.zero?
    end
  end

  ##
  # @param uuid Beacon filtering uuid
  # @param id selfball ID
  # @param led (:mutex, :colors, :interval)
  # @param lcd (:modified, :error)
  # @param favorite (:modified, :v)
  def initialize(uuid, id, led, lcd, favorite)
    logs = BeaconLog.new
    loop do
      cmd = { proc: 'node', file: 'beacon.js', uuid: uuid, major: id, minor: favorite[:v], measure: -59 }.freeze
      Open3.popen3(cmd.values.join(' ')) do |_i, o, _e, w|
        @end_monitor = false
        th = Thread.new { monitor_beacon_stop(w.pid, favorite) }
        o.each { |log| monitor_beacon_log(logs, log, led, lcd, w.pid) }
        th.join
      end
    end
  end
end
