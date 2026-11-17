# -*- coding: utf-8 -*-
import glob, os
from PIL import Image, ImageDraw, ImageFont

SRC = r'E:\GithubRepo\game-buyhouse\art\_work\raw\freepixel\buildings'
OUT = r'E:\GithubRepo\game-buyhouse\art\_work\fpx_sheet.png'

files = sorted(f for f in glob.glob(os.path.join(SRC, 'urban-*.png')))
print(len(files), 'urban files')
sizes = {}
for f in files:
    im = Image.open(f)
    sizes[im.size] = sizes.get(im.size, 0) + 1
print('sizes:', sizes)

font = ImageFont.truetype(r'C:\Windows\Fonts\consola.ttf', 9)
COLS = 8
CW, CH = 170, 200
rows = (len(files) + COLS - 1) // COLS
sheet = Image.new('RGB', (COLS * CW, rows * CH), (40, 40, 46))
d = ImageDraw.Draw(sheet)
for i, f in enumerate(files):
    im = Image.open(f).convert('RGBA')
    col, row = i % COLS, i // COLS
    x, y = col * CW, row * CH
    # 等比缩放到 150x150 以内，最近邻
    s = min(150 / im.width, 150 / im.height)
    big = im.resize((max(1, int(im.width * s)), max(1, int(im.height * s))), Image.NEAREST)
    sheet.paste(big, (x + (CW - big.width) // 2, y + 8 + (150 - big.height) // 2), big)
    name = os.path.basename(f).replace('urban-', '').replace('-2026-03-25T19-14-54.png', '')
    d.text((x + 4, y + 165), name[:30], font=font, fill=(220, 220, 220))
    d.text((x + 4, y + 178), str(im.size), font=font, fill=(150, 150, 160))
sheet.save(OUT)
print('saved', OUT, sheet.size)
