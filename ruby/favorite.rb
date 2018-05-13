# frozen_string_literal: true

require 'json'

##
# read/write favorite in selfball.
module Favorite
  PATH = 'favorite.json'
  DEFAULT_FAVORITE = 0

  def read
    write(DEFAULT_FAVORITE) unless File.exist? PATH
    data = File.open(PATH, 'r', &:read)
    JSON.parse(data)['favorite'].to_i
  rescue StandardError => e
    puts e
    write(DEFAULT_FAVORITE)
    DEFAULT_FAVORITE
  end

  def write(fav)
    data = { favorite: fav }.to_json
    File.open(PATH, 'w') { |f| f.write(data) }
  end

  module_function :read, :write
end

if $PROGRAM_NAME == __FILE__
  if ARGV.empty?
    puts Favorite.read
  else
    Favorite.write(ARGV.first.to_i)
  end
end
