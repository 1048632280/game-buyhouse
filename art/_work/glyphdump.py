# -*- coding: utf-8 -*-
from PIL import ImageFont
import glob

paths = glob.glob(r'E:\GithubRepo\game-buyhouse\art\_work\raw\font\**\*zh_cn*.ttf', recursive=True)
chars = '转基因大豆防毒面具奶粉黄金手机电脑摩托车汽车'

for p in paths:
    f = ImageFont.truetype(p, 16)
    print('=====', p.split('\\')[-2], p.split('\\')[-1])
    for ch in chars[:4]:
        m = f.getmask(ch)
        w, h = m.size
        print(f'--- {ch} size={m.size}')
        if w == 0:
            print('   (empty)')
            continue
        for y in range(h):
            print('   ' + ''.join('#' if m.getpixel((x, y)) else '.' for x in range(w)))
