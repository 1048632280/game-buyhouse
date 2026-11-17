import sys, os
from PIL import Image, ImageDraw, ImageFont

# 用法: tiles_pick.py <tile_dir> <out> <comma-separated indices> [scale] [cols]
d, out = sys.argv[1], sys.argv[2]
idxs = [int(x) for x in sys.argv[3].split(',')]
scale = int(sys.argv[4]) if len(sys.argv) > 4 else 6
cols = int(sys.argv[5]) if len(sys.argv) > 5 else 8

font = ImageFont.truetype(r'C:\Windows\Fonts\consola.ttf', 11)
cell = 16 * scale + 2
lab = 14
rows = (len(idxs) + cols - 1) // cols
sheet = Image.new('RGB', (cols * cell, rows * (cell + lab)), (34, 34, 40))
dr = ImageDraw.Draw(sheet)
for i, idx in enumerate(idxs):
    f = os.path.join(d, f'tile_{idx:04d}.png')
    r, c = divmod(i, cols)
    px, py = c * cell + 1, r * (cell + lab) + 1
    if os.path.exists(f):
        im = Image.open(f).convert('RGBA').resize((16 * scale, 16 * scale), Image.NEAREST)
        for yy in range(py, py + 16 * scale, 8):
            for xx in range(px, px + 16 * scale, 8):
                if (xx // 8 + yy // 8) % 2 == 0:
                    dr.rectangle([xx, yy, xx + 7, yy + 7], fill=(52, 52, 60))
        sheet.paste(im, (px, py), im)
    dr.text((px, py + 16 * scale - 12), str(idx), font=font, fill=(255, 210, 90))
sheet.save(out)
print(out, sheet.size)
