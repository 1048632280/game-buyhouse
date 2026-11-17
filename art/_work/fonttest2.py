# -*- coding: utf-8 -*-
import sys
from PIL import Image, ImageDraw, ImageFont

FONTS = [
    (r'E:\GithubRepo\game-buyhouse\art\_work\raw\font\cubic11.ttf', 11),
    (r'E:\GithubRepo\game-buyhouse\art\_work\raw\font\cubic11.ttf', 22),
    (r'E:\GithubRepo\game-buyhouse\art\_work\raw\font\ark16may\ark-pixel-16px-monospaced-zh_cn.ttf', 16),
]
lines = [
    '买房记  v1.3',
    '现金：123,456 元   存款：1,200 万',
    '出租屋(37/100)  市场  售楼部  彩票',
    '转基因大豆 38 / 防毒面具 210 / 奶粉 320',
    '晴天  多云  暴雨  雨加雪  暴雪',
]

rows = []
for path, size in FONTS:
    f = ImageFont.truetype(path, size)
    for ln in lines:
        rows.append((f, ln, size))

pad = 8
H = sum(size + pad for _, _, size in rows) + 20
W = 620
im = Image.new('RGB', (W, H), (255, 255, 255))
d = ImageDraw.Draw(im)
y = 10
for f, ln, size in rows:
    d.text((10, y), ln, font=f, fill=(20, 20, 20))
    y += size + pad
im = im.resize((im.width * 2, im.height * 2), Image.NEAREST)
im.save(r'E:\GithubRepo\game-buyhouse\art\_work\fonttest2.png')
print('saved', im.size)
