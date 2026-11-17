# -*- coding: utf-8 -*-
import os, sys
from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from sprites import GOODS, WEATHER, BADGE, PANEL, BTN, BTN_DOWN

FONT = r'E:\GithubRepo\game-buyhouse\art\_work\raw\font\ark\ark-pixel-16px-monospaced-zh_cn.ttf'
SCALE = 5
BG = (0xE9, 0xD4, 0xD0)
INK = (0x3F, 0x26, 0x31)

font = ImageFont.truetype(FONT, 16)

def tile_cell(im, label, font, pad=10):
    w = max(im.width * SCALE, font.getlength(label) if hasattr(font, 'getlength') else 80)
    return int(w) + pad * 2

def draw_row(items, y, dr, pad=10, gap=8):
    x = pad
    for label, im in items:
        big = im.resize((im.width * SCALE, im.height * SCALE), Image.NEAREST)
        dr.text((x, y), label, font=font, fill=INK)
        dr._image.paste(big, (x, y + 22), big)
        x += max(big.width, int(font.getlength(label))) + gap
    return x

rows = [
    [(n, im) for _, n, im in GOODS],
    list(WEATHER.items()),
]

W = 1100
row_h = 16 * SCALE + 40
H = len(rows) * row_h + 200
sheet = Image.new('RGB', (W, H), BG)
dr = ImageDraw.Draw(sheet)
dr._image = sheet

y = 12
for row in rows:
    draw_row(row, y, dr)
    y += row_h

# 徽章 / UI
extra = [('成就徽章', BADGE), ('面板', PANEL), ('按钮', BTN), ('按钮按下', BTN_DOWN)]
x = 10
for label, im in extra:
    big = im.resize((im.width * SCALE, im.height * SCALE), Image.NEAREST)
    dr.text((x, y), label, font=font, fill=INK)
    sheet.paste(big, (x, y + 22), big)
    x += big.width + 24

sheet.save(r'E:\GithubRepo\game-buyhouse\art\_work\sheet_icons.png')
print('saved', sheet.size)
