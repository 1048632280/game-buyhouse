import sys, os
from PIL import Image

def zoom(src, out_prefix, scale=4, max_side=1800):
    im = Image.open(src).convert('RGBA')
    w, h = im.size
    print(f'{os.path.basename(src)}: {w}x{h}')
    big = im.resize((w*scale, h*scale), Image.NEAREST)
    # 切成若干竖条，便于逐块查看
    n = max(1, (big.width + max_side - 1) // max_side)
    step = (big.width + n - 1) // n
    for i in range(n):
        box = (i*step, 0, min((i+1)*step, big.width), big.height)
        part = big.crop(box)
        # 棋盘底，便于看透明区
        bg = Image.new('RGBA', part.size, (40, 40, 40, 255))
        for y in range(0, part.height, 16):
            for x in range(0, part.width, 16):
                if (x//16 + y//16) % 2 == 0:
                    bg.paste((70, 70, 70, 255), (x, y, x+16, y+16))
        bg.alpha_composite(part)
        out = f'{out_prefix}_{i}.png'
        bg.convert('RGB').save(out)
        print('  ->', out, bg.size)

if __name__ == '__main__':
    zoom(sys.argv[1], sys.argv[2], int(sys.argv[3]) if len(sys.argv) > 3 else 4)
