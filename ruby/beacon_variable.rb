# frozen_string_literal: true

require 'open3'
require 'json'
require './beacon_log'
require './favorite'

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
      next unless favorite[:modified] || @found_matched_selfball
      Process.kill(:KILL, pid)
      puts %(kill process : #{pid})
      break
    end
  end

  ##
  # @param logs [BeaconLog]
  # @param log [String]
  # @param led [Struct] (:mutex, :colors, :interval)
  # @param lcd [Struct] (:modified, :error)
  # @param favorite [Integer]
  private def monitor_beacon_log(logs, log, led, lcd, favorite)
    logs.add(JSON.parse(log, symbolize_names: true))
    cand = candidates(logs, favorite)
    return if cand.empty?
    winner = cand.keys.max_by { |k| cand[k].to_s(2).count('1') }
    puts %(matched #{winner})
    mod_led_lcd(led, lcd, fav2colors(cand[winner]), FLUSH_LED_INTERVAL)
    @found_matched_selfball = true
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
    colors = %w[red blue green yellow]
    colors.each.with_index.flat_map do |color, i|
      (fav & (0b1111 << (i * 4))).zero? ? [] : color
    end
  end

  ##
  # @param cmd start beacon command
  # @param favorite (:modified)
  # @param led (:mutex, :colors, :interval)
  # @param lcd (:modified, :error)
  private def start_beacon(cmd, favorite, led, lcd)
    logs = BeaconLog.new
    Open3.popen3(cmd.values.join(' ')) do |_i, o, _e, w|
      puts %(start process : #{w.pid})
      @found_matched_selfball = false
      favorite[:modified] = false
      th = Thread.new { monitor_beacon_stop(w.pid, favorite) }
      o.each { |log| monitor_beacon_log(logs, log, led, lcd, cmd[:minor]) }
      th.join
    end
  end

  ##
  # @param uuid Beacon filtering uuid
  # @param id selfball ID
  # @param led (:mutex, :colors, :interval)
  # @param lcd (:modified, :error)
  # @param favorite (:modified)
  def initialize(uuid, id, led, lcd, favorite)
    loop do
      fav = Favorite.read
      p cmd = {
        proc: 'node', file: 'beacon.js',
        uuid: uuid, major: id, minor: fav, measure: -59
      }
      start_beacon(cmd, favorite, led, lcd)
      sleep(FLUSH_LED_INTERVAL) if @found_matched_selfball
    end
  end
end
