##
# Modify static ip 192.168.11.201 - 220

require './selfball'

id = Selfball.id
if id.nil?
  puts 'Undefined selfball ID.'
  exit 1
end

path = '/etc/dhcpcd.conf'.freeze
txt = File.open(path, 'r', &:read)
r = /static\s+ip_address=\d+\.\d+\.\d+\.\d+/
ip = %(192.168.11.#{200 + id.to_i})
txt.gsub!(r, %(static ip_address=#{ip}))
File.open(path, 'w') { |f| f.write(txt) }
