require './led'
require './lcd'
require './bcm2835'
require './selfball'
require './reporter'

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
mode = ARGV.first
if mode.nil?
  puts 'you should select start mode.'
  exit 3
end
puts %(My id is #{id}.)
puts %(Mode is #{mode})

lcd = Struct.new(:modified, :error).new(false, false)
led = Struct.new(:modified, :mutex, :colors, :interval).new(true, Mutex.new, [], 0)

case mode.downcase
when 'wifi', 'wi-fi'
  require './beacon_const'
  require './server_led'
  require './beacon_log'
  uuid = 'B9407F30-F5F8-466E-AFF9-25556B57FE6D'.delete('-').downcase.freeze
  logs = BeaconLog.new
  [
    Thread.new { Led.new(led) },
    Thread.new { Lcd.new(lcd) },
    Thread.new { BeaconConst.new(uuid, id, logs) },
    Thread.new { Reporter.new(id, logs, lcd) },
    Thread.new { ServerLed.new(led, lcd) }
  ].each(&:join)
when 'ble'
  raise 'not implemented'
when 'video'
  require './server_led'
  [
    Thread.new { Led.new(led) },
    Thread.new { Lcd.new(lcd) },
    Thread.new { ServerLed.new(led, lcd) }
  ].each(&:join)
else
  raise 'you should select start mode.'
end
