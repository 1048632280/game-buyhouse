# -*- coding: utf-8 -*-
"""生成 1024x1024 App 图标：纸色底 + 像素高楼 + 细描边。"""
import json, os
from PIL import Image, ImageDraw

ROOT = r'E:\GithubRepo\game-buyhouse\ios\BuyHouse\Resources\Assets.xcassets'
BUILD = r'E:\GithubRepo\game-buyhouse\art\ios\buildings\estate.png'

PAL = {
    'K': (0x3F, 0x26, 0x31),
    'P': (0xE9, 0xD4, 0xD0),
    'C': (0xC0, 0xCB, 0xDC),
    'Y': (0xFD, 0xBE, 0x53),
    'R': (0xC3, 0x4B, 0x35),
}

S = 1024
img = Image.new('RGB', (S, S), PAL['P'])
d = ImageDraw.Draw(img)

# 顶部一条淡色天
d.rectangle([0, 0, S, S // 3], fill=PAL['C'])

b = Image.open(BUILD).convert('RGBA')
scale = min((S - 160) // b.width, (S - 220) // b.height)
big = b.resize((b.width * scale, b.height * scale), Image.NEAREST)
img.paste(big, ((S - big.width) // 2, S - 70 - big.height), big)

# 圆角遮罩 + 描边
mask = Image.new('L', (S, S), 0)
ImageDraw.Draw(mask).rounded_rectangle([0, 0, S - 1, S - 1], radius=180, fill=255)
out = Image.new('RGBA', (S, S), (0, 0, 0, 0))
out.paste(img, (0, 0), mask)
ImageDraw.Draw(out).rounded_rectangle([2, 2, S - 3, S - 3], radius=178, outline=PAL['K'], width=10)

icon_dir = os.path.join(ROOT, 'AppIcon.appiconset')
os.makedirs(icon_dir, exist_ok=True)
out.convert('RGB').save(os.path.join(icon_dir, 'AppIcon.png'))
with open(os.path.join(icon_dir, 'Contents.json'), 'w', encoding='utf-8') as f:
    json.dump({
        'images': [{'filename': 'AppIcon.png', 'idiom': 'universal', 'platform': 'ios', 'size': '1024x1024'}],
        'info': {'author': 'xcode', 'version': 1},
    }, f, indent=2)
print('icon saved', os.path.join(icon_dir, 'AppIcon.png'))
