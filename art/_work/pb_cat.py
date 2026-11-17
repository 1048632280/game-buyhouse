# -*- coding: utf-8 -*-
"""按分类列出 pixel-buildings 的正面(s)视角，用于挑选。"""
import glob, json, os, sys
from PIL import Image, ImageDraw, ImageFont

ROOT = r'E:\GithubRepo\game-buyhouse\art\_work\raw\pb\pixel-buildings-main\buildings'


def front(d):
    p = os.path.join(d, 'summer.json')
    js = json.load(open(p, encoding='utf-8'))
    a = js['angles']['s']
    img = Image.open(os.path.join(d, js['image'])).convert('RGBA')
    return img.crop((a['x'], a['y'], a['x'] + a['w'], a['y'] + a['h']))


def sheet(cat, out, cols=5, maxn=20):
    dirs = sorted(d for d in glob.glob(os.path.join(ROOT, cat + '-*')) if os.path.isdir(d))[:maxn]
    font = ImageFont.truetype(r'C:\Windows\Fonts\consola.ttf', 9)
    CW, CH = 150, 200
    rows = (len(dirs) + cols - 1) // cols
    im = Image.new('RGB', (cols * CW, rows * CH), (46, 46, 52))
    dr = ImageDraw.Draw(im)
    for i, d in enumerate(dirs):
        b = front(d)
        col, row = i % cols, i // cols
        x, y = col * CW, row * CH
        s = min(130 / b.width, 155 / b.height, 1.0)
        big = b.resize((int(b.width * s), int(b.height * s)), Image.LANCZOS)
        im.paste(big, (x + (CW - big.width) // 2, y + 8 + (155 - big.height)), big)
        dr.text((x + 4, y + 170), os.path.basename(d)[:26], font=font, fill=(230, 230, 230))
        dr.text((x + 4, y + 183), f'{b.width}x{b.height}', font=font, fill=(150, 150, 160))
    im.save(out)
    print('saved', out, im.size, len(dirs))


if __name__ == '__main__':
    sheet(sys.argv[1], sys.argv[2])
