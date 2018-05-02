import sys
import cv2

a = cv2.imread(sys.argv[1], 1)
if a is None or a.shape[0] is 0:
    print('failed to open image')
    quit()

for y in range(a.shape[0]):
    for x in range(a.shape[1]):
        bgr = a[y][x]
        # to rgb 565
        b = bgr[0] >> 3
        g = bgr[1] >> 2
        r = bgr[2] >> 3
        s = (r << 11) | (g << 5) | b
        s0 = s >> 8
        s1 = s & 0xFF
        print('%d,%d,' % (s0, s1), end="")

print()