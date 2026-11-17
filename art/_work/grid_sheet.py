import sys, os
from PIL import Image, ImageDraw, ImageFont

# 从打包 tilesheet 里按行渲染带索引的视图
# 用法: grid_sheet.py <sheet.png> <out_prefix> <start_row> <rows> [scale] [cols] [tile] [margin]
src, prefix, start_row, rows = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4])
scale = int(sys.argv[5]) if len(sys.argv) > 5 else 4
cols = int(sys.argv[6]) if len(sys.argv) > 6 else 49
tile = int(sys.argv[7]) if len(sys.argv) > 7 else 16
margin = int(sys.argv[8]) if len(sys.argv) > 8 else 1

im = Image.open(src).convert('RGBA')
font = ImageFont.truetype(r'C:\Windows\Fonts\consola.ttf', 10)
cell = tile * scale + 2
label_h = 12
W = cols * cell
H = rows * (cell + label_h)
out = Image.new('RGB', (W, H), (34, 34, 40))
d = ImageDraw.Draw(out)
for r in range(rows):
    for c in range(cols):
        x0 = c * (tile + margin)
        y0 = (start_row + r) * (tile + margin)
        if x0 + tile > im.width or y0 + tile > im.height:
            continue
        part = im.crop((x0, y0, x0 + tile, y0 + tile))
        part = part.resize((tile * scale, tile * scale), Image.NEAREST)
        px = c * cell + 1
        py = r * (cell + label_h) + 1
        for yy in range(py, py + cell - 2, 8):
            for xx in range(px, px + cell - 2, 8):
                if (xx // 8 + yy // 8) % 2 == 0:
                    d.rectangle([xx, yy, xx + 7, yy + 7], fill=(52, 52, 60))
        out.paste(part, (px, py), part)
        idx = (start_row + r) * cols + c
        d.text((px, py + cell - 13), str(idx), font=font, fill=(255, 210, 90))

name = f'{prefix}_{start_row}.png'
out.save(name)
print(name, out.size)
