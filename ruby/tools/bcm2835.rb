require 'fiddle/import'

##
# simulator
module SPI
  CS0 = 0
  CS1 = 1
  extend Fiddle::Importer
  dlload './libsimulator.dylib'
  extern 'void write(unsigned char *, int)'
end

##
# BCM 2835
module BCM
  def bcm2835_init
    1
  end
  module_function :bcm2835_init
end
