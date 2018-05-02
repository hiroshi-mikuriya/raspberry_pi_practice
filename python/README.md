# セルフボールの目の画像をバイナリ値に変換する

セルフボールの２つのLCD（両目）に表示する画像はBMPなどではなく特殊なフォーマットなので、pythonのOpenCVを使って変換する

目の画像自体は画像編集ツール（Paint.NETなど）で作る

|色|横幅|縦幅|
|:---|:---|:---|
|24bits RGB|96pix|64pix|

LCDに表示するフォーマット  
RGBの順に565bitsずつ96*64ピクセル分ならべたバイナリデータ

## OpenCVインストール手順

```
$ brew install pyenv
$ echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile
$ echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile
$ echo 'eval "$(pyenv init -)"' >> ~/.bash_profile
$ pyenv install anaconda3-4.2.0
$ pyenv global anaconda3-4.2.0
$ sudo conda install -c menpo opencv3
```

## 参考

[MacユーザーのためのPythonでOpenCVを使うための開発環境](https://lp-tech.net/articles/uJsYp)