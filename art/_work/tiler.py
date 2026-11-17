import sys, os, math
from PIL import Image

def checker(size, s=8):
    bg = Image.new('RGBA', size, (46, 46, 52, 255))
    for y in range(0, size[1], s):
        for x in range(0, size[0], s):
            if (x // s + y // s) % 2 == 0:
                bg.paste((66, 66, 74, 255), (x, y, x + s, y + s))
    return bg

def tile(src, out_prefix, scale=5, max_out=760):
    im = Image.open(src).convert('RGBA')
    w, h = im.size
    step = max(16, max_out // scale)
    cols = math.ceil(w / step)
    rows = math.ceil(h / step)
    print(f'{os.path.basename(src)} {w}x{h} -> {cols}x{rows} tiles @{scale}x')
    for r in range(rows):
        for c in range(cols):
            box = (c * step, r * step, min((c + 1) * step, w), min((r + 1) * step, h))
            part = im.crop(box)
            if part.size[0] < 2 or part.size[1] < 2:
                continue
            big = part.resize((part.width * scale, part.height * scale), Image.NEAREST)
            bg = checker(big.size, 8)
            bg.alpha_composite(big)
            out = f'{out_prefix}_r{r}c{c}.png'
            bg.convert('RGB').save(out)

if __name__ == '__main__':
    tile(sys.argv[1], sys.argv[2], int(sys.argv[3]) if len(sys.argv) > 3 else 5)
