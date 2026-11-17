# -*- coding: utf-8 -*-
from PIL import ImageFont
import glob

text = '转基因大豆防毒面具奶粉黄金手机电脑摩托车汽车晴天多云出租屋现金存款健康声望中介售楼部彩票成就重新开始'
NOTDEF = '\ue000'  # 私用区，必定缺字

paths = glob.glob(r'E:\GithubRepo\game-buyhouse\art\_work\raw\font\ark16may\*zh_cn*.ttf') + \
        glob.glob(r'E:\GithubRepo\game-buyhouse\art\_work\raw\font\ark\*zh_cn*.ttf')
for p in paths:
    f = ImageFont.truetype(p, 16)
    ref = bytes(f.getmask(NOTDEF))
    bad = []
    for ch in text:
        m = f.getmask(ch)
        if m.size == (0, 0) or bytes(m) == ref:
            bad.append(ch)
    print(p.split('\\')[-1], '| missing:', ''.join(bad) or 'none')
