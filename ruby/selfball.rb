# frozen_string_literal: true

##
# SELFBALL
module Selfball
  MAC2ID = {
    'b8:27:eb:21:2b:6c' => '1',
    'b8:27:eb:ef:87:62' => '2',
    'b8:27:eb:c2:81:89' => '3',
    'b8:27:eb:27:35:22' => '4',
    'b8:27:eb:27:b8:ab' => '5',
    'b8:27:eb:64:90:03' => '6',
    'b8:27:eb:85:07:7f' => '7',
    'b8:27:eb:35:b4:da' => '8',
    'b8:27:eb:68:05:e1' => '9',
    'b8:27:eb:de:1c:c7' => '10',
    'b8:27:eb:31:0c:57' => '11',
    'b8:27:eb:17:45:c8' => '12',
    'b8:27:eb:7e:fa:a2' => '13',
    'b8:27:eb:4f:c3:e3' => '14',
    'b8:27:eb:27:f9:6c' => '15',
    'b8:27:eb:d9:11:c8' => '16',
    'b8:27:eb:51:98:d4' => '17',
    'b8:27:eb:31:b4:af' => '18',
    'b8:27:eb:0c:75:d3' => '19',
    'b8:27:eb:08:a1:14' => '20'
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
