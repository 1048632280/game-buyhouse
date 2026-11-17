# -*- coding: utf-8 -*-
from PIL import Image, ImageFont, ImageDraw
import sys

paths = [
    r'E:\GithubRepo\game-buyhouse\art\_work\raw\font\ark\ark-pixel-16px-monospaced-zh_cn.ttf',
    r'E:\GithubRepo\game-buyhouse\art\_work\raw\font\ark\ark-pixel-16px-monospaced-ja.ttf',
    r'E:\GithubRepo\game-buyhouse\art\_work\raw\font\ark\ark-pixel-16px-monospaced-zh_hk.ttf',
]
text = '转基因大豆防毒面具奶粉黄金手机电脑摩托车汽车晴天多云'

try:
    from fontTools.ttLib import TTFont
    have_ft = True
except Exception:
    have_ft = False
print('fontTools:', have_ft)

for p in paths:
    f = ImageFont.truetype(p, 16)
    missing = []
    for ch in text:
        bbox = f.getbbox(ch)
        # .notdef 在像素字体里通常渲染成一个方框
        m = f.getmask(ch)
        if m.size[0] == 0 and m.size[1] == 0:
            missing.append(ch)
    print(p.split('\\')[-1], 'empty-glyph chars:', ''.join(missing) or 'none')
    if have_ft:
        tt = TTFont(p)
        cmap = tt.getBestCmap()
        miss = [c for c in text if ord(c) not in cmap]
        print('   cmap missing:', ''.join(miss) or 'none', '| cmap size', len(cmap))
        tt.close()
