require './led'
require './lcd'
require './server'
require './beacon_monitor'
require './bcm2835'
require 'thread'

##
# WLAN Mac address -> Selfball ID
MAC2ID = {
  'b8:27:eb:ef:87:62' => '1',
  'b8:27:eb:21:2b:6c' => '2',
  'b8:27:eb:85:07:7f' => '3' # TODO: add more 17 selfballs
}.freeze

##
# Obtain 'SELFBALL ID' from raspberry pi wlan0 mac address
def selfball_id
  mac = /ether\s+(\S+)/.match(`ifconfig wlan0`)[1] # WLAN mac address
  if mac.nil?
    puts 'failed to get wlan0 mac address'
    exit 1
  end
  MAC2ID[mac.downcase]
end

puts Time.now
Thread.abort_on_exception = true # exit process if except in thread
if BCM.bcm2835_init.zero?
  puts 'failed to init bcm2835.'
  exit 1
end
id = selfball_id
if id.nil?
  puts 'Not defined selfball ID.'
  exit 1
end
puts %(My id is #{id}.)
uuid = 'b9407f30f5f8466eaff925556b57fe6d'
lcd = { modified: false }
led = { modified: true, mutex: Mutex.new, v: [] }
[
  Thread.new { Led.new(led) },
  Thread.new { Lcd.new(lcd) },
  Thread.new { Server.new(id, lcd, led) },
  Thread.new { BeaconMonitor.new(uuid, lcd, led) },
  Thread.new { system("node beacon.js #{uuid} 5 #{id} -59") } # start advertising
].each(&:join)