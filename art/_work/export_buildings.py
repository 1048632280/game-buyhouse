# -*- coding: utf-8 -*-
"""从 pixel-buildings 导出 8 档房屋正面图，裁掉透明边，输出到 art/ios/buildings/。"""
import json, os
from PIL import Image

ROOT = r'E:\GithubRepo\game-buyhouse\art\_work\raw\pb\pixel-buildings-main\buildings'
OUT = r'E:\GithubRepo\game-buyhouse\art\ios\buildings'
os.makedirs(OUT, exist_ok=True)

# 代码里的 8 档 -> (素材目录, 说明)
PICKS = [
    ('studio', '07-02-flat-fronted-town-house', '单身公寓'),
    ('oldhouse', '07-14-crooked-house-over-an-archway', '二手旧房'),
    ('uptown', '09-01-brick-block', '高档小区'),
    ('luxury', '09-00-mansard-block', '豪华住宅'),
    ('lakevilla', '07-05-canal-house', '湖景别墅'),
    ('poolvilla', '09-15-hanging-garden-block', '泳池私宅'),
    ('complex', '09-04-courtyard-block-in-a-u', '一栋小区'),
    ('estate', '09-08-twin-towers-joined-by-a-bridge', '一个楼盘'),
]


def front(d):
    js = json.load(open(os.path.join(d, 'summer.json'), encoding='utf-8'))
    a = js['angles']['s']
    img = Image.open(os.path.join(d, js['image'])).convert('RGBA')
    return img.crop((a['x'], a['y'], a['x'] + a['w'], a['y'] + a['h']))


manifest = []
for code, folder, name in PICKS:
    src = os.path.join(ROOT, folder)
    im = front(src)
    bbox = im.getbbox()
    if bbox:
        im = im.crop(bbox)
    path = os.path.join(OUT, f'{code}.png')
    im.save(path)
    manifest.append({'code': code, 'name': name, 'file': f'{code}.png',
                     'size': list(im.size), 'source': folder})
    print(f'{code:10s} {name:6s} {im.size}  <- {folder}')

with open(os.path.join(OUT, 'buildings.json'), 'w', encoding='utf-8') as f:
    json.dump(manifest, f, ensure_ascii=False, indent=1)
print('exported', len(manifest))
