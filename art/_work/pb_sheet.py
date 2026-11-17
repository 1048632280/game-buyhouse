# -*- coding: utf-8 -*-
"""从 pixel-buildings 里裁出正面(s)视角，做风格对比表。"""
import glob, json, os
from PIL import Image, ImageDraw, ImageFont

ROOT = r'E:\GithubRepo\game-buyhouse\art\_work\raw\pb\pixel-buildings-main\buildings'
OUT = r'E:\GithubRepo\game-buyhouse\art\_work\pb_sheet.png'

def front(path):
    js = json.load(open(path, encoding='utf-8'))
    fw, fh = js['frame_size']
    a = js['angles']['s']
    return Image.open(os.path.join(os.path.dirname(path), js['image'])).convert('RGBA').crop(
        (a['x'], a['y'], a['x'] + a['w'], a['y'] + a['h']))

cats = ['01', '02', '07', '09', '10', '19']
font = ImageFont.truetype(r'C:\Windows\Fonts\consola.ttf', 9)
CW, CH = 140, 190
picked = []
for c in cats:
    dirs = sorted(d for d in glob.glob(os.path.join(ROOT, c + '-*')) if os.path.isdir(d))[:5]
    for d in dirs:
        p = os.path.join(d, 'summer.json')
        if os.path.exists(p):
            picked.append((os.path.basename(d), front(p)))

cols = 5
rows = (len(picked) + cols - 1) // cols
sheet = Image.new('RGB', (cols * CW, rows * CH), (46, 46, 52))
dr = ImageDraw.Draw(sheet)
for i, (name, im) in enumerate(picked):
    col, row = i % cols, i // cols
    x, y = col * CW, row * CH
    s = min(120 / im.width, 150 / im.height, 1.0)
    big = im.resize((int(im.width * s), int(im.height * s)), Image.LANCZOS)
    sheet.paste(big, (x + (CW - big.width) // 2, y + 10 + (150 - big.height)), big)
    dr.text((x + 4, y + 165), name[:24], font=font, fill=(225, 225, 225))
    dr.text((x + 4, y + 177), f'{im.width}x{im.height}', font=font, fill=(150, 150, 160))
sheet.save(OUT)
print('saved', OUT, sheet.size, len(picked), 'buildings')
