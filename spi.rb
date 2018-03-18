require'./bcm2835'

if BCM.bcm2835_init.zero?
  warn 'failedtoinitbcm2835'
  exit1
end

CS0 = 0

def write_spi(tx)
  rx = ([0] * tx.size).pack('C*')
  BCM.bcm2835_spi_begin
  BCM.bcm2835_spi_setBitOrder(1) # MSB First
  BCM.bcm2835_spi_setDataMode(0) # CPOL = 0, CPHA = 0
  BCM.bcm2835_spi_setClockDivider(64) # 64 = 256ns = 3.90625MHz
  BCM.bcm2835_spi_chipSelect(CS0) # Chip Select 0
  BCM.bcm2835_spi_setChipSelectPolarity(CS0, 0) # LOW
  # rx = BCM.bcm2835_spi_transfer(tx)
  # BCM.bcm2835_spi_writenb(tx, tx.size)
  BCM.bcm2835_spi_transfernb(tx, rx, tx.size)
  puts tx == rx ? 'success' : "error #{tx} != #{rx}"
  BCM.bcm2835_spi_end
end

loop do
  tx = %w[2 0 0 55 AA].map(&:hex).pack('c*')
  write_spi(tx)
  sleep(1)
end

BCM.bcm2835_close
