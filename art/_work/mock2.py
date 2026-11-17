# -*- coding: utf-8 -*-
"""主界面布局稿：固定底栏 + 卡片列表 + 4 列操作。"""
import json, os, sys
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from sprites import PAL, GOODS, WEATHER, BADGE, PANEL, BTN

FONT = os.path.join(HERE, 'raw', 'font', 'ark12', 'ark-pixel-12px-monospaced-zh_hans.ttf')
F12 = ImageFont.truetype(FONT, 12)
F24 = ImageFont.truetype(FONT, 24)
INK, SUB, PAPER, BG = PAL['K'], PAL['N'], PAL['P'], PAL['C']
ITEM = {c: m for c, n, m in GOODS}

W, H = 390, 844
HPAD = 10
CW = W - HPAD * 2

img = Image.new('RGB', (W, H), BG)
d = ImageDraw.Draw(img)


def nine_slice(src, x, y, w, h, c=6):
    sw, sh = src.size
    parts = [(0, 0, c, c), (c, 0, sw - c, c), (sw - c, 0, sw, c),
             (0, c, c, sh - c), (c, c, sw - c, sh - c), (sw - c, c, sw, sh - c),
             (0, sh - c, c, sh), (c, sh - c, sw - c, sh), (sw - c, sh - c, sw, sh)]
    pos = [(0, 0), (c, 0), (w - c, 0), (0, c), (c, c), (w - c, c), (0, h - c), (c, h - c), (w - c, h - c)]
    ww = [c, w - 2 * c, c, c, w - 2 * c, c, c, w - 2 * c, c]
    hh = [c, c, c, h - 2 * c, h - 2 * c, h - 2 * c, c, c, c]
    for (a, b, cc, dd), (ox, oy), pw, ph in zip(parts, pos, ww, hh):
        if pw <= 0 or ph <= 0:
            continue
        piece = src.crop((a, b, cc, dd))
        if piece.size != (pw, ph):
            piece = piece.resize((pw, ph), Image.NEAREST)
        img.paste(piece, (x + ox, y + oy), piece)


def panel(x, y, w, h, title=None):
    nine_slice(PANEL, x, y, w, h)
    if title:
        tw = F12.getlength(title)
        d.rectangle([x + 10, y - 7, x + 10 + tw + 10, y + 6], fill=PAPER)
        d.text((x + 15, y - 8), title, font=F12, fill=INK)


def button(x, y, w, h, label, primary=False):
    nine_slice(BTN if primary else PANEL, x, y, w, h)
    d.text((x + (w - F12.getlength(label)) / 2, y + (h - 16) / 2), label, font=F12, fill=INK)


def icon(im, x, y, s=2):
    big = im.resize((im.width * s, im.height * s), Image.NEAREST)
    img.paste(big, (x, y), big)


# ---------- 状态条 ----------
d.rectangle([0, 0, W, 44], fill=PAPER)
icon(WEATHER['多云'], HPAD + 2, 10, 2)
d.text((HPAD + 44, 13), '多云', font=F12, fill=INK)
wk = '第 12 周'
d.text((W - HPAD - 2 - F12.getlength(wk), 13), wk, font=F12, fill=SUB)
d.line([(0, 44), (W, 44)], fill=INK, width=1)

y = 56

# ---------- 个人信息 ----------
PH = 104
panel(HPAD, y, CW, PH, '个人信息')
label_w = 46
for i, (k, v) in enumerate([('现 金', '1,234,567 元'), ('存 款', '120 万'), ('余X宝', '8.5 万')]):
    ry = y + 12 + i * 24
    d.text((HPAD + 12, ry), k, font=F12, fill=SUB)
    d.text((HPAD + 12 + label_w, ry), v, font=F12, fill=INK)
for i, (lab, val, col) in enumerate([('健康', 82, 'R'), ('声望', 45, 'L')]):
    bx, by = 226, y + 14 + i * 34
    d.text((bx, by), lab, font=F12, fill=SUB)
    bar_w = 66
    d.rectangle([bx + 30, by + 1, bx + 30 + bar_w, by + 11], fill=PAL['C'], outline=INK)
    d.rectangle([bx + 32, by + 3, bx + 32 + int((bar_w - 4) * val / 100), by + 9], fill=PAL[col])
    d.text((bx + 30 + bar_w + 8, by), str(val), font=F12, fill=INK)
y += PH + 10

# ---------- 出租屋 ----------
room = [('beans', '转基因大豆', 38, 12), ('mask', '防毒面具', 210, 5), ('gold', '黄金', 1560, 2)]
RH = 44
PH = 16 + RH * len(room) + 4
panel(HPAD, y, CW, PH, '出租屋 37/100')
for i, (code, name, buy, num) in enumerate(room):
    ry = y + 12 + i * RH
    icon(ITEM[code], HPAD + 12, ry, 2)
    d.text((HPAD + 54, ry + 1), name, font=F12, fill=INK)
    d.text((HPAD + 54, ry + 18), f'买入价 {buy}', font=F12, fill=SUB)
    q = f'×{num}'
    bx = W - HPAD - 12 - 52 - 10 - F12.getlength(q)
    d.text((bx, ry + 9), q, font=F12, fill=INK)
    button(W - HPAD - 12 - 52, ry + 8, 52, 28, '卖出')
    if i < len(room) - 1:
        d.line([(HPAD + 12, ry + RH - 2), (W - HPAD - 12, ry + RH - 2)], fill=PAL['C'])
y += PH + 10

# ---------- 市场 ----------
market = [('phone', '手机', 4200), ('computer', '电脑', 9800), ('milk', '奶粉', 320)]
PH = 16 + RH * len(market) + 4
panel(HPAD, y, CW, PH, '市场 · 本周行情')
for i, (code, name, price) in enumerate(market):
    ry = y + 12 + i * RH
    icon(ITEM[code], HPAD + 12, ry, 2)
    d.text((HPAD + 54, ry + 1), name, font=F12, fill=INK)
    d.text((HPAD + 54, ry + 18), f'{price} 元', font=F12, fill=SUB)
    button(W - HPAD - 12 - 52, ry + 8, 52, 28, '买入', primary=True)
    if i < len(market) - 1:
        d.line([(HPAD + 12, ry + RH - 2), (W - HPAD - 12, ry + RH - 2)], fill=PAL['C'])
y += PH + 10

# ---------- 成就 ----------
owned = ['成为百万富翁', '拥有一所房屋', '度过1年']
PH = 108
panel(HPAD, y, CW, PH, f'成就 3/11')
col_w = (CW - 24) / 3
for i, name in enumerate(owned):
    cx = int(HPAD + 12 + i * col_w + col_w / 2)
    big = BADGE.resize((32, 32), Image.NEAREST)
    img.paste(big, (int(cx - 16), y + 16), big)
    d.text((cx - F12.getlength(name) / 2, y + 56), name, font=F12, fill=INK)
    d.text((cx - 16, y + 74), '已获得', font=F12, fill=PAL['E'])
y += PH + 10

# ---------- 操作 ----------
PH = 108
panel(HPAD, y, CW, PH, '操作')
acts = ['医院', '健身房', '银行', '余X宝', '中介', '彩票', '售楼部', '成就']
gap = 8
bw = int((CW - 24 - gap * 3) / 4)
for i, a in enumerate(acts):
    col, row = i % 4, i // 4
    button(HPAD + 12 + col * (bw + gap), y + 14 + row * 40, bw, 32, a)
y += PH + 10

# ---------- 底部固定栏 ----------
bar_y = H - 64
d.rectangle([0, bar_y, W, H], fill=BG)
d.line([(0, bar_y), (W, bar_y)], fill=INK, width=1)
d.text((HPAD, bar_y + 12), '健康 82', font=F12, fill=SUB)
d.text((HPAD, bar_y + 32), '库存 37/100', font=F12, fill=SUB)
button(HPAD + 76, bar_y + 9, W - HPAD * 2 - 76, 46, '过一周', primary=True)

img.resize((W * 2, H * 2), Image.NEAREST).save(r'E:\GithubRepo\game-buyhouse\art\preview\04_layout_main.png')
print('saved 04_layout_main.png')

