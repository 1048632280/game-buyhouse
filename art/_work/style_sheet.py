# -*- coding: utf-8 -*-
"""素材清单确认图：货物 / 天气 / 房屋 / 组件 / 字体 / 调色板。"""
import os, sys
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from sprites import PAL, GOODS, WEATHER, BADGE, PANEL, BTN
from build_buildings import house, tower

FONT = os.path.join(HERE, 'raw', 'font', 'cubic11.ttf')
F11 = ImageFont.truetype(FONT, 11)
F22 = ImageFont.truetype(FONT, 22)

INK, SUB, BG, CARD = PAL['K'], PAL['N'], PAL['C'], PAL['P']
W, H = 1000, 1320
img = Image.new('RGB', (W, H), BG)
d = ImageDraw.Draw(img)
cursor = 0


def section(y, title):
    d.text((20, y), title, font=F22, fill=INK)
    d.line([(20, y + 30), (W - 20, y + 30)], fill=INK, width=2)
    return y + 46


def label(text, cx, y, color=INK):
    d.text((cx - F11.getlength(text) / 2, y), text, font=F11, fill=color)


# ---- 货物 ----
y = section(14, '货物 8 种 · 16×16 · 与 Tiny City 共用同一套调色板')
for i, (code, name, im) in enumerate(GOODS):
    cx = 68 + i * 118
    big = im.resize((64, 64), Image.NEAREST)
    img.paste(big, (cx - 32, y + 8), big)
    label(name, cx, y + 80)
cursor = y + 104

# ---- 天气 ----
y = section(cursor, '天气 14 种 · 云 / 雨 / 雪 / 雾 图层合成，不单独画 14 张')
for i, (name, im) in enumerate(WEATHER.items()):
    col, row = i % 7, i // 7
    cx, cy = 68 + col * 140, y + 10 + row * 96
    big = im.resize((48, 48), Image.NEAREST)
    img.paste(big, (cx - 24, cy), big)
    label(name, cx, cy + 52)
cursor = y + 196

# ---- 房屋 ----
y = section(cursor, '房屋 8 档 · Tiny City 瓦片拼装，规模递增')
houses = [
    ('单身公寓', '30m²', house(2, 2, 'brown', 'brown', 'brown')),
    ('二手旧房', '80m²', house(2, 2, 'brown', 'red', 'red')),
    ('高档小区', '108m²', tower(3, 2)),
    ('豪华住宅', '180m²', house(3, 2, 'brown', 'brown', 'brown', 'double')),
    ('湖景别墅', '320m²', house(4, 2, 'brown', 'red', 'red', 'double')),
    ('泳池私宅', '450m²', house(5, 2, 'blue', 'brown', 'brown', 'double')),
    ('一栋小区', '1512m²', tower(4, 3)),
    ('一个楼盘', '24192m²', tower(5, 4)),
]
CELL_W, CELL_H = 240, 224
for i, (name, m2, im) in enumerate(houses):
    col, row = i % 4, i // 4
    cx, cy = 30 + col * CELL_W + CELL_W // 2, y + row * CELL_H
    big = im.resize((im.width * 2, im.height * 2), Image.NEAREST)
    img.paste(big, (cx - big.width // 2, cy + 158 - big.height), big)
    label(name, cx, cy + 164)
    label(m2, cx, cy + 180, SUB)
cursor = y + CELL_H * 2 - 10

# ---- 组件 ----
y = section(cursor, '组件与字体')
x = 30
for im, name, s in [(BADGE, '成就星章', 4), (PANEL, '面板（9-slice）', 4), (BTN, '按钮（9-slice）', 4)]:
    big = im.resize((im.width * s, im.height * s), Image.NEAREST)
    img.paste(big, (x, y + 8), big)
    d.text((x, y + 8 + big.height + 8), name, font=F11, fill=INK)
    x += big.width + 46

fx = 430
d.text((fx, y + 4), 'Cubic 11 · 11px', font=F11, fill=SUB)
d.text((fx, y + 24), '买房记 v1.3    第 12 周    晴天', font=F11, fill=INK)
d.text((fx, y + 52), 'Cubic 11 · 22px', font=F11, fill=SUB)
d.text((fx, y + 70), '现金 1,234,567 元', font=F22, fill=INK)
cursor = y + 150

# ---- 调色板 ----
y = section(cursor, '调色板 · Tiny City 全图统计出 33 色，补画素材只允许用这些')
keys = ['K', 'D', 'B', 'N', 'M', 'G', 'C', 'P', 'R', 'O', 'Y', 'L', 'E', 'U']
for i, k in enumerate(keys):
    bx = 20 + i * 68
    d.rectangle([bx, y + 6, bx + 56, y + 62], fill=PAL[k], outline=INK)
    d.text((bx + 4, y + 66), k, font=F11, fill=INK)
cursor = y + 96

img = img.crop((0, 0, W, cursor + 10))
img.save(os.path.join(HERE, 'style_sheet.png'))
print('saved style_sheet.png', img.size)

