require 'open3'

Open3.popen2('./myspi') do |i, _o|
  loop do
    d = %w[1 2 3 4].map(&:hex).pack('C*')
    i.write d
    sleep(1)
  end
end
