export OUT=raw.rb

echo 'ERROR_LEFT,ERROR_RIGHT,OPEN,CLOSE,COLOR = (0...5).to_a' > $OUT
echo 'RAW_SIZE = 96 * 64 * 2 # = 0x3000' >> $OUT
echo 'RAWS = {' >> $OUT

echo 'ERROR_LEFT => [' >> $OUT
python conv.py left.bmp >> $OUT
echo '],' >> $OUT

echo 'ERROR_RIGHT => [' >> $OUT
python conv.py right.bmp >> $OUT
echo '],' >> $OUT

echo 'OPEN => [' >> $OUT
python conv.py open.bmp >> $OUT
echo '],' >> $OUT

echo 'CLOSE => [' >> $OUT
python conv.py close.bmp >> $OUT
echo '],' >> $OUT

echo 'COLOR => [' >> $OUT
python conv.py color.bmp >> $OUT
echo ']' >> $OUT

echo '}.freeze' >> $OUT