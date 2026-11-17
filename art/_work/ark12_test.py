# -*- coding: utf-8 -*-
from PIL import Image, ImageDraw, ImageFont

FONT = r'E:\GithubRepo\game-buyhouse\art\_work\raw\font\ark12\ark-pixel-12px-monospaced-zh_hans.ttf'
lines = [
    '买房记 v1.3',
    '现金：123,456 元   存款：1,200 万',
    '出租屋(37/100)  市场  售楼部  彩票',
    '转基因大豆 38 / 防毒面具 210 / 奶粉 320',
    '晴天 多云 暴雨 雨加雪 暴雪',
]
sizes = [12, 24, 36]
H = sum(s * 1.6 for s in sizes) * len(lines) + 40
W = 680
im = Image.new('RGB', (W, int(H)), (255, 255, 255))
d = ImageDraw.Draw(im)
y = 10
for s in sizes:
    f = ImageFont.truetype(FONT, s)
    for ln in lines:
        d.text((10, y), ln, font=f, fill=(20, 20, 20))
        y += int(s * 1.6)
im = im.resize((im.width * 2, im.height * 2), Image.NEAREST)
im.save(r'E:\GithubRepo\game-buyhouse\art\_work\ark12_test.png')
print('saved', im.size)
