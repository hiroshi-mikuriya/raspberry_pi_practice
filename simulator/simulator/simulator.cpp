#include <opencv2/opencv.hpp>

namespace {
    int CS = 0;
    const float inner = 230;
    const float outer = inner + 10;
    const float light = 5;
    const cv::Size canvas_size(500, 500);
    std::vector<uint8_t> buffer0(0x1800);
    std::vector<uint8_t> buffer1(96 * 64 * 2 * 6);

    void showLed()
    {
        cv::Mat canvas = cv::Mat::zeros(canvas_size, CV_8UC3);
        cv::Point c(canvas.cols / 2, canvas.rows / 2);
        uint8_t const * p = buffer0.data() + 0x1000;
        for(int i = 0; i < 32; ++i) {
            double a = 2 * CV_PI * (i % 16) / 16;
            double r = (i < 16) ? inner : outer;
            cv::Point2f pt(c.x + sin(a) * r, c.y + cos(a) * r);
            auto rgb = p + 3 * i;
            cv::Scalar color(rgb[2], rgb[1], rgb[0]);
            cv::circle(canvas, pt, light, color, CV_FILLED);
        }
        cv::imshow("LED", canvas);
        cv::waitKey(1);
    }
    
    cv::Mat makeMat(uint8_t const * p, int w, int h)
    {
        cv::Mat m(h, w, CV_8UC3);
        for(int y = 0; y < h; ++y){
            for(int x = 0; x < w; ++x){
                auto pp = p + (x + y * w) * 2;
                uint16_t s = (*pp << 8) + pp[1];
                uint8_t r = (s >> 11) << 3;
                uint8_t g = ((s >> 5) & 0x3F) << 2;
                uint8_t b = (s & 0x1F) << 3;
                m.at<cv::Vec3b>(y, x) = cv::Vec3b(b, g, r);
            }
        }
        return m;
    }
    
    void showLcd()
    {
        int ix = buffer0[1];
        int lix = ix >> 4;
        int rix = ix & 0xf;
        cv::Size const sizeOfEye(96, 64);
        cv::Rect const rectOfLeft(cv::Point(304, 150), sizeOfEye);
        cv::Rect const rectOfRight(cv::Point(100, 150), sizeOfEye);
        cv::Mat left = makeMat(buffer1.data() + lix * sizeOfEye.area() * 2, sizeOfEye.width, sizeOfEye.height);
        cv::Mat right = makeMat(buffer1.data() + rix * sizeOfEye.area() * 2, sizeOfEye.width, sizeOfEye.height);
        cv::Mat canvas = cv::Mat::zeros(canvas_size, CV_8UC3);
        cv::Point const center(canvas.cols / 2, canvas.rows / 2);
        cv::circle(canvas, center, center.x, cv::Scalar::all(0xFF), CV_FILLED);
        left.copyTo(canvas(rectOfLeft));
        right.copyTo(canvas(rectOfRight));
        cv::rectangle(canvas, rectOfLeft, cv::Scalar::all(0x40));
        cv::rectangle(canvas, rectOfRight, cv::Scalar::all(0x40));
        cv::imshow("LCD", canvas);
    }
    
    void show()
    {
        showLed();
        showLcd();
        cv::waitKey(1);
    }
}

extern "C" int bcm2835_init(void){return 1;}
extern "C" int bcm2835_close(void){return 0;}
extern "C" void  bcm2835_set_debug(unsigned char debug){}
extern "C" unsigned int bcm2835_version(void){return 0;}
extern "C" unsigned int* bcm2835_regbase(unsigned char regbase){return 0;}
extern "C" unsigned int bcm2835_peri_read(volatile unsigned int* paddr){return 0;}
extern "C" unsigned int bcm2835_peri_read_nb(volatile unsigned int* paddr){return 0;}
extern "C" void bcm2835_peri_write(volatile unsigned int* paddr, unsigned int value){}
extern "C" void bcm2835_peri_write_nb(volatile unsigned int* paddr, unsigned int value){}
extern "C" void bcm2835_peri_set_bits(volatile unsigned int* paddr, unsigned int value, unsigned int mask){}
extern "C" void bcm2835_gpio_fsel(unsigned char pin, unsigned char mode){}
extern "C" void bcm2835_gpio_set(unsigned char pin){}
extern "C" void bcm2835_gpio_clr(unsigned char pin){}
extern "C" void bcm2835_gpio_set_multi(unsigned int mask){}
extern "C" void bcm2835_gpio_clr_multi(unsigned int mask){}
extern "C" unsigned char bcm2835_gpio_lev(unsigned char pin){return 0;}
extern "C" unsigned char bcm2835_gpio_eds(unsigned char pin){return 0;}
extern "C" void bcm2835_gpio_set_eds(unsigned char pin){}
extern "C" void bcm2835_gpio_ren(unsigned char pin){}
extern "C" void bcm2835_gpio_clr_ren(unsigned char pin){}
extern "C" void bcm2835_gpio_fen(unsigned char pin){}
extern "C" void bcm2835_gpio_clr_fen(unsigned char pin){}
extern "C" void bcm2835_gpio_hen(unsigned char pin){}
extern "C" void bcm2835_gpio_clr_hen(unsigned char pin){}
extern "C" void bcm2835_gpio_len(unsigned char pin){}
extern "C" void bcm2835_gpio_clr_len(unsigned char pin){}
extern "C" void bcm2835_gpio_aren(unsigned char pin){}
extern "C" void bcm2835_gpio_clr_aren(unsigned char pin){}
extern "C" void bcm2835_gpio_afen(unsigned char pin){}
extern "C" void bcm2835_gpio_clr_afen(unsigned char pin){}
extern "C" void bcm2835_gpio_pud(unsigned char pud){}
extern "C" void bcm2835_gpio_pudclk(unsigned char pin, unsigned char on){}
extern "C" unsigned int bcm2835_gpio_pad(unsigned char group){return 0;}
extern "C" void bcm2835_gpio_set_pad(unsigned char group, unsigned int control){}
extern "C" void bcm2835_delay (unsigned int millis){}
extern "C" void bcm2835_delayMicroseconds (unsigned long long micros){}
extern "C" void bcm2835_gpio_write(unsigned char pin, unsigned char on){}
extern "C" void bcm2835_gpio_write_multi(unsigned int mask, unsigned char on){}
extern "C" void bcm2835_gpio_write_mask(unsigned int value, unsigned int mask){}
extern "C" void bcm2835_gpio_set_pud(unsigned char pin, unsigned char pud){}
extern "C" void bcm2835_spi_begin(void){}
extern "C" void bcm2835_spi_end(void){}
extern "C" void bcm2835_spi_setBitOrder(unsigned char order){}
extern "C" void bcm2835_spi_setClockDivider(unsigned short divider){}
extern "C" void bcm2835_spi_setDataMode(unsigned char mode){}
extern "C" void bcm2835_spi_chipSelect(unsigned char cs)
{
    if(0 == cs || 1 == cs) {
        CS = cs;
    }
}
extern "C" void bcm2835_spi_setChipSelectPolarity(unsigned char cs, unsigned char active){}
extern "C" unsigned char bcm2835_spi_transfer(unsigned char value){return 0;}
extern "C" void bcm2835_spi_transfernb(char* tbuf, char* rbuf, unsigned int len){}
extern "C" void bcm2835_spi_transfern(char* buf, unsigned int len){}
extern "C" void bcm2835_spi_writenb(char* buf, unsigned int len)
{
    uint16_t addr = (buf[1] << 8) + buf[2];
    auto & buffer = (CS == 0)? buffer0 : buffer1;
    uint8_t const * p = reinterpret_cast<uint8_t*>(buf + 3);
    std::copy(p, p + len, buffer.data() + addr);
    show();
}
extern "C" void bcm2835_i2c_begin(void){}
extern "C" void bcm2835_i2c_end(void){}
extern "C" void bcm2835_i2c_setSlaveAddress(unsigned char addr){}
extern "C" void bcm2835_i2c_setClockDivider(unsigned short divider){}
extern "C" void bcm2835_i2c_set_baudrate(unsigned int baudrate){}
extern "C" unsigned char bcm2835_i2c_write(const char * buf, unsigned int len){return 0;}
extern "C" unsigned char bcm2835_i2c_read(char* buf, unsigned int len){return 0;}
extern "C" unsigned char bcm2835_i2c_read_register_rs(char* regaddr, char* buf, unsigned int len){return 0;}
extern "C" unsigned char bcm2835_i2c_write_read_rs(char* cmds, unsigned int cmds_len, char* buf, unsigned int buf_len){return 0;}
extern "C" unsigned long long bcm2835_st_read(void){return 0;}
extern "C" void bcm2835_st_delay(unsigned long long offset_micros, unsigned long long micros){}
extern "C" void bcm2835_pwm_set_clock(unsigned int divisor){}
extern "C" void bcm2835_pwm_set_mode(unsigned char channel, unsigned char markspace, unsigned char enabled){}
extern "C" void bcm2835_pwm_set_range(unsigned char channel, unsigned int range){}
extern "C" void bcm2835_pwm_set_data(unsigned char channel, unsigned int data){}
