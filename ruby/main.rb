require './led'
require './lcd'
require './bcm2835'
require './selfball'

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
led = Struct.new(:mutex, :colors, :interval).new(Mutex.new, [], 0)

case mode.downcase
when 'wifi', 'wi-fi'
  require './beacon_const'
  require './server_led'
  require './beacon_log'
  require './reporter'
  uuid = '11112222-3333-4444-5555-666677778888'.delete('-').downcase.freeze # TODO: mod other uuid
  logs = BeaconLog.new
  [
    Thread.new { Led.new(led) },
    Thread.new { Lcd.new(lcd) },
    Thread.new { BeaconConst.new(uuid, id, logs) },
    Thread.new { Reporter.new(id, logs, lcd) },
    Thread.new { ServerLed.new(led, lcd) }
  ].each(&:join)
when 'ble'
  require './beacon_variable'
  require './server_favorite'
  uuid = 'B9407F30-F5F8-466E-AFF9-25556B57FE6D'.delete('-').downcase.freeze
  favorite = Struct.new(:modified).new(false)
  [
    Thread.new { Led.new(led) },
    Thread.new { Lcd.new(lcd) },
    Thread.new { BeaconVariable.new(uuid, id, led, lcd, favorite) },
    Thread.new { ServerFavorite.new(favorite) }
  ].each(&:join)
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
