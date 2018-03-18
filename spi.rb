require 'open3'

Open3.popen('./myspi') do |io|
  d = %w[1 2 3 4].map(&:hex).pack('C*')
  io.puts d
  sleep(1)
end
