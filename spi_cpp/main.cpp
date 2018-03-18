#include <iostream>
#include <string>
#include <vector>
#include <bcm2835.h>

int main(int argv, char ** argc)
{
    if (!bcm2835_init()){
        std::cerr << "failed bcm2835_init()" << std::endl;
        return 1;
    }        
    for(;;) {
        std::string s;
        std::cin >> s;
        bcm2835_spi_begin();
        bcm2835_spi_setBitOrder(BCM2835_SPI_BIT_ORDER_MSBFIRST);      // The default
        bcm2835_spi_setDataMode(BCM2835_SPI_MODE0);                   // The default. Clock polarity = 0(Positive), Clock phase = 0(Positive)
        bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_64); // Not default. 32 = 128ns = 7.8125MHz
        //bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_64); // Not default. Divide 64 = 256ns = 3.90625MHz
        bcm2835_spi_chipSelect(BCM2835_SPI_CS0);                      // The default
        bcm2835_spi_setChipSelectPolarity(BCM2835_SPI_CS0, LOW);      // the default        
        bcm2835_spi_writenb(const_cast<char*>(s.data()), s.size());        
        bcm2835_spi_end();
        bcm2835_close();
    }
    return 0;
}
