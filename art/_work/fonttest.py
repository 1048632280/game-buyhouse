# -*- coding: utf-8 -*-
from PIL import Image, ImageDraw, ImageFont

FONT = r'E:\GithubRepo\game-buyhouse\art\_work\raw\font\ark\ark-pixel-16px-monospaced-zh_cn.ttf'
lines = ['转基因大豆 防毒面具 奶粉 黄金', '手机 电脑 摩托车 汽车', '晴天 多云 阴天 雾 雷阵雨', '现  金：1,234,567 元', '出租屋(3/100) 售楼部 余X宝']
sizes = [16, 32]
H = 0
for s in sizes:
    H += len(lines) * (s + 10)
im = Image.new('RGB', (760, H + 20), (255, 255, 255))
d = ImageDraw.Draw(im)
y = 10
for s in sizes:
    f = ImageFont.truetype(FONT, s)
    for ln in lines:
        d.text((10, y), ln, font=f, fill=(20, 20, 20))
        y += s + 10
im = im.resize((im.width * 2, im.height * 2), Image.NEAREST)
im.save(r'E:\GithubRepo\game-buyhouse\art\_work\fonttest.png')
print('saved', im.size)
