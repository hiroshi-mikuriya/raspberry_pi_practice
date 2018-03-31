# Raspberry Pi Zeroであれこれ

## Raspberry Pi Zeroのセットアップ手順についての備忘録

### OSインストールからSSHまで

以下からOSをダウンロード  
http://ftp.jaist.ac.jp/pub/raspberrypi/raspbian/images/

現時点での最新を選ぶ  
2018-03-13-raspbian-stretch.zip

SDカードをMacBookに挿しこみ、EtcherでOSをSDカードに書き込む

SDカードのルートに、sshという名前の空ファイルを置く（sshでログイン可能になる）

USB-OTGで接続するために、以下２つのファイルを変更する
* config.txt  
  dtoverlay=dwc2を追記
* cmdline.txt  
  rootwait と quiet の間に modules-load=dwc2,g_ether を追記

SDカードをRaspberry Pi Zeroに挿しこむ。  
マイクロUSBケーブルでMacと繋ぐ。（2つあるUSBコネクタはPWRではなくUSBを選択）

TODO: Macの初期設定をする（詳細はそのうち記述する）

Macのターミナルから以下コマンドを入力するとSSHでログインできる。  
`ssh pi@raspberrypi.local`  
以前にも繋いだことがある場合に警告がでることがあるが、そのときはsudoで実行すればOK  

### Wi-Fiにつなぐ

以下コマンドを入力する（SSID PASSPHRASEは適切に設定すること）  
`$ sudo sh -c 'wpa_passphrase SSID PASSPHRASE >> /etc/wpa_supplicant/wpa_supplicant.conf'`

パスワードだけなぜかコメントアウトされているので、#を消す  
`$ sudo vim /etc/wpa_supplicant/wpa_supplicant.conf'`

これでWi-Fiにつながる。

### FTP有効化

`$ sudo apt-get upgrade && sudo apt-get update`  
`$ sudo apt-get install vsftpd`  
FTPは上記以降も設定があるので以下を参照のこと  
http://yamaryu0508.hatenablog.com/entry/2014/12/02/102648

### リモートデスクトップ有効化

`$ sudo apt-get install xrdp`

Macやwindowsのリモートデスクトップクライアントからアクセスする。  
|key|value|
|-|-|
|URL|raspberrypi.local|
|user|pi|
|password|raspberry|

### SPI有効化

私はviよりvimのほうが使いやすいので、vimをインストールする  
`$ sudo apt-get install vim`

/etc/modules に追記  

`snd-bcm2835`  
`spidev`  

コンフィグ画面でSPIを有効にする  
`$ sudo raspi-config`  
- 5 Interfacing Options  
- P4 SPI -> enable  
- P5 I2C -> enable  

SPI開通確認  
`ls -la /dev/spidev*`

結果  
`crw-rw---- 1 root spi 153, 0 Mar 27 14:28 /dev/spidev0.0`  
`crw-rw---- 1 root spi 153, 1 Mar 27 14:28 /dev/spidev0.1`

### bcm2835をインストールする

bcm2835はRaspberryPiのIOを操作するライブラリ  

`$ sudo wget http://www.airspayce.com/mikem/bcm2835/bcm2835-1.44.tar.gz`  
`$ tar zxvf bcm2835-1.44.tar.gz`  
`$ cd bcm2835-1.44/`  
`$ sudo ./configure`  
`$ sudo make`  
`$ cd src`  
`$ cc -shared bcm2835.o -o libbcm2835.so`  
`$ cd ../`  
`$ sudo make install`  
`$ sudo mv src/libbcm2835.so /usr/local/lib`

上記でbcm2835をso形式にしたのはFiddleを使ってRubyから直接呼び出すため。  
bcm2835のgemもあるが、うまくインストールできなかったのでfiddleを使って操作することとした。

## Rubyプロセスをデーモン化する

`$ sudo gem install daemons`

require 'daemons'をして、Daemons.process内部に処理を記述すると、rubyがデーモンプロセスになる。
さらにraspberry pi起動時に自動実行するには、/etc/rc.localにそのrubyを実行する処理を以下のように記述する。  
`$ cd /home/pi/workspace/`  
`$ sudo ruby main.rb start`

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
* bcm2835(gem)  
https://github.com/joshnuss/bcm2835
