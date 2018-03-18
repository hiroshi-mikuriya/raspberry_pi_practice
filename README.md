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