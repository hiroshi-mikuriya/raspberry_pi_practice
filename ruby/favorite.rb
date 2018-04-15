require 'json'

##
# read/write Favorite
module FAVORITE
  PATH = 'favorite.json'.freeze

  def read
    v = 0
    File.open(PATH, 'r') { |f| v = JSON.parse(f.read, symbolize_names: true)[:v] }
  rescue
    puts 'create initial file.'
    write(v)
  ensure
    v
  end

  def write(favorite)
    v = { v: favorite }
    File.open(PATH, 'w') { |f| f << v.to_json }
  end

  module_function :read, :write
end
