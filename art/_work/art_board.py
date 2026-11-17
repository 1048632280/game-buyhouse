# -*- coding: utf-8 -*-
"""美术资源总览大图：房屋 / 货物 / 天气 / 组件 / 字体 / 调色板。"""
import json, os, sys
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from sprites import PAL, GOODS, WEATHER, BADGE, PANEL, BTN

OUT = r'E:\GithubRepo\game-buyhouse\art\preview\00_art_board.png'
BDIR = r'E:\GithubRepo\game-buyhouse\art\ios\buildings'
ARK = os.path.join(HERE, 'raw', 'font', 'ark12', 'ark-pixel-12px-monospaced-zh_hans.ttf')

LABEL = r'C:\Windows\Fonts\msyh.ttc'
F18 = ImageFont.truetype(LABEL, 18)
F22 = ImageFont.truetype(LABEL, 22)
F30 = ImageFont.truetype(LABEL, 30)
F42 = ImageFont.truetype(LABEL, 42)
ARK12 = ImageFont.truetype(ARK, 12)
ARK24 = ImageFont.truetype(ARK, 24)
ARK36 = ImageFont.truetype(ARK, 36)

INK = PAL['K']
SUB = PAL['N']
BG = (0xEE, 0xE4, 0xDF)
CARD = (0xF7, 0xEF, 0xEA)

W = 1600
img = Image.new('RGB', (W, 2600), BG)
d = ImageDraw.Draw(img)
y = 30


def section(title, hint=''):
    global y
    d.text((40, y), title, font=F42, fill=INK)
    if hint:
        d.text((40 + F42.getlength(title) + 16, y + 16), hint, font=F18, fill=SUB)
    y += 58
    d.line([(40, y), (W - 40, y)], fill=INK, width=3)
    y += 18


# ---------------- 标题 ----------------
d.text((40, y), '买房记 · iOS 美术资源总览', font=F42, fill=INK)
d.text((40, y + 54), '房屋来自 pixel-buildings（CC0，600 栋选 8），图标与天气为自绘（16×16），字体方舟像素 12px',
       font=F18, fill=SUB)
y += 110

# ---------------- 房屋 ----------------
buildings = json.load(open(os.path.join(BDIR, 'buildings.json'), encoding='utf-8'))
section('房屋 8 档', '等距像素建筑，按规模递增；原始尺寸 60×72 ~ 130×169，显示时 2x')
CELL_W, CELL_H = 380, 400
for i, b in enumerate(buildings):
    col, row = i % 4, i // 4
    cx = 40 + col * CELL_W
    cy = y + row * CELL_H
    d.rounded_rectangle([cx, cy, cx + CELL_W - 16, cy + CELL_H - 16], 4, fill=CARD)
    im = Image.open(os.path.join(BDIR, b['file'])).convert('RGBA')
    big = im.resize((im.width * 2, im.height * 2), Image.NEAREST)
    box_h = 330
    img.paste(big, (cx + (CELL_W - 16 - big.width) // 2, cy + box_h - big.height), big)
    d.text((cx + 16, cy + 8), b['name'], font=F22, fill=INK)
    d.text((cx + 16, cy + 36), f"{b['size'][0]}×{b['size'][1]}  {b['code']}", font=F18, fill=SUB)
y += CELL_H * 2 + 10

# ---------------- 货物 ----------------
section('货物 8 种', '16×16 自绘，按 Tiny City 33 色调色板，显示 2x')
for i, (code, name, im) in enumerate(GOODS):
    cx = 40 + i * 190
    d.rounded_rectangle([cx, y, cx + 174, y + 190], 4, fill=CARD)
    big = im.resize((96, 96), Image.NEAREST)
    img.paste(big, (cx + 39, y + 20), big)
    d.text((cx + 87 - F22.getlength(name) / 2, y + 130), name, font=F22, fill=INK)
    d.text((cx + 87 - F18.getlength(code) / 2, y + 158), code, font=F18, fill=SUB)
y += 210

# ---------------- 天气 ----------------
section('天气 14 种', '云 / 雨 / 雪 / 雾 四层合成，显示 2x')
for i, (name, im) in enumerate(WEATHER.items()):
    col, row = i % 7, i // 7
    cx = 40 + col * 220
    cy = y + row * 170
    d.rounded_rectangle([cx, cy, cx + 204, cy + 150], 4, fill=CARD)
    big = im.resize((64, 64), Image.NEAREST)
    img.paste(big, (cx + 70, cy + 12), big)
    d.text((cx + 102 - F22.getlength(name) / 2, cy + 96), name, font=F22, fill=INK)
y += 360

# ---------------- 组件 ----------------
section('组件与字体')
x = 40
for im, label, s in [(BADGE, '成就星章 16×16', 6), (PANEL, '面板 9-slice 24×24', 6), (BTN, '按钮 9-slice 24×24', 6)]:
    big = im.resize((im.width * s, im.height * s), Image.NEAREST)
    d.rounded_rectangle([x, y, x + 220, y + 220], 4, fill=CARD)
    img.paste(big, (x + (220 - big.width) // 2, y + 20), big)
    d.text((x + 12, y + 196), label, font=F18, fill=SUB)
    x += 240

fx = 800
d.text((fx, y + 6), '方舟像素 12px · 字号只用 12 / 24 / 36', font=F18, fill=SUB)
d.text((fx, y + 34), '现金 1,234,567 元', font=ARK12, fill=INK)
d.text((fx, y + 60), '出租屋 (37/100) 售楼部', font=ARK24, fill=INK)
d.text((fx, y + 104), '买房记', font=ARK36, fill=INK)
d.text((fx, y + 158), '缺字：雾 翁 奖（iOS 自动回退系统字体）', font=F18, fill=SUB)
y += 250

# ---------------- 调色板 ----------------
section('调色板', 'Tiny City 全图统计 33 色，自绘素材只用这些')
keys = ['K', 'D', 'B', 'N', 'M', 'G', 'C', 'P', 'R', 'O', 'Y', 'L', 'E', 'U']
for i, k in enumerate(keys):
    bx = 40 + i * 108
    d.rounded_rectangle([bx, y, bx + 88, y + 88], 4, fill=PAL[k], outline=INK, width=2)
    d.text((bx + 4, y + 96), f'{k} #{PAL[k][0]:02X}{PAL[k][1]:02X}{PAL[k][2]:02X}', font=F18, fill=SUB)
y += 140

img = img.crop((0, 0, W, y))
img.save(OUT)
print('saved', OUT, img.size)
