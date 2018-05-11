##
# SELFBALL
module Selfball
  MAC2ID = {
    'b8:27:eb:ef:87:62' => '1',
    'b8:27:eb:21:2b:6c' => '2',
    'undefined 3' => '3',
    'b8:27:eb:27:35:22' => '4',
    'b8:27:eb:27:b8:ab' => '5',
    'b8:27:eb:64:90:03' => '6',
    'b8:27:eb:85:07:7f' => '7',
    'b8:27:eb:35:b4:da' => '8',
    'b8:27:eb:68:05:e1' => '9',
    'b8:27:eb:de:1c:c7' => '10',
    'undefined 11' => '11',
    'undefined 12' => '12',
    'undefined 13' => '13',
    'undefined 14' => '14',
    'undefined 15' => '15',
    'undefined 16' => '16',
    'undefined 17' => '17',
    'undefined 18' => '18',
    'undefined 19' => '19',
    'undefined 20' => '20'
  }.freeze

  ##
  # Obtain 'SELFBALL ID' from raspberry pi wlan0 mac address
  def id
    m = /ether\s+(\S+)/.match(`ifconfig wlan0`)
    return nil if m.nil?
    mac = m[1] # WLAN mac address
    return nil if mac.nil?
    MAC2ID[mac.downcase]
  end

  module_function :id
end
