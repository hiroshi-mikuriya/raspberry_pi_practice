require './led'
require './lcd'
require './beacon'
require './bcm2835'
require './selfball'
require './reporter'
require './server'
require 'thread'

Thread.abort_on_exception = true # exit process if except in thread
if BCM.bcm2835_init.zero?
  puts 'failed to init bcm2835.'
  exit 1
end
id = Selfball.id
if id.nil?
  puts 'Undefined selfball ID.'
  exit 2
end
puts %(My id is #{id}.)
uuid = 'B9407F30-F5F8-466E-AFF9-25556B57FE6D'.delete('-').downcase.freeze
lcd = Struct.new(:modified, :error).new(false, false)
led = Struct.new(:modified, :mutex, :colors, :interval).new(true, Mutex.new, [], 0)
default_logs = Hash.new { |h, k| h[k] = [] }
beacon_logs = Struct.new(:v, :mutex).new(default_logs, Mutex.new)
[
  Thread.new { Led.new(led) },
  Thread.new { Lcd.new(lcd) },
  Thread.new { Beacon.new(uuid, id, beacon_logs) },
  Thread.new { Reporter.new(id, beacon_logs, lcd) },
  Thread.new { Server.new(led, lcd) }
].each(&:join)
