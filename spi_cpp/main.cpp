#include <iostream>
#include <string>
#include <vector>
#include <bcm2835.h>

namespace
{
    void transmit(std::string const & tx)
    {
        if (!bcm2835_init()){
            return;
        }        
        bcm2835_spi_begin();
        bcm2835_spi_setBitOrder(BCM2835_SPI_BIT_ORDER_MSBFIRST);      // The default
        bcm2835_spi_setDataMode(BCM2835_SPI_MODE0);                   // The default. Clock polarity = 0(Positive), Clock phase = 0(Positive)
        bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_64); // Not default. 32 = 128ns = 7.8125MHz
        //bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_64); // Not default. Divide 64 = 256ns = 3.90625MHz
        bcm2835_spi_chipSelect(BCM2835_SPI_CS0);                      // The default
        bcm2835_spi_setChipSelectPolarity(BCM2835_SPI_CS0, LOW);      // the default        
        bcm2835_spi_writenb(const_cast<char*>(tx.data()), tx.size());        
        bcm2835_spi_end();
        bcm2835_close();
    }
}

int main(int argv, char ** argc)
{
    for(;;) {
        std::string s;
        std::cin >> s;
        transmit(s);
    }
    return 0;
}
