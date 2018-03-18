# Raspberry PiでSPIやI2Cを行う練習

## やったこと

`$ sudo raspi-config`  
- 5 Interfacing Options  
- P4 SPI -> enable  
- P5 I2C -> enable  

/etc/modules に追記  
> snd-bcm2835  
spidev  
i2c-bcm2708  
i2c-dev
spi_bcm2835

SPI開通確認  
`ls -la /dev/spidev*`

I2C開通確認  
`sudo i2cdetect -y 1`

## 参考URL

* Raspberry PIで温度湿度センサーをRubyで動かす  
https://qiita.com/cattaka/items/43745dde59e7f2b4988d  
* Raspberry Pi の I2C を有効化する方法 (2015年版)  
https://blog.ymyzk.com/2015/02/enable-raspberry-pi-i2c/
* Raspberry PiでSPI通信機能を利用する（NTP時計を無線LAN化する）  
http://www.soramimi.jp/raspberrypi/spi/
* Raspberry Pi ZeroをUSBケーブル1本で遊ぶ  
https://www.raspi.jp/2016/07/pizero-usb-otg/
* ラズベリーパイ】GPIOライブラリ｢pi_piper」のご紹介
http://www.kibanhonpo.com/lab/pi_piper/
* bcm2835 ライブラリによるスイッチ入力とLEDの点滅  
https://tomosoft.jp/design/?p=5252
* bcm2835.h  
http://www.airspayce.com/mikem/bcm2835/bcm2835_8h_source.html