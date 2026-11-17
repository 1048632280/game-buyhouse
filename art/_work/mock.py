# -*- coding: utf-8 -*-
"""iPhone 界面确认图（390x844，2x）：主界面 + 售楼部。字体 Ark Pixel 12px。"""
import json, os, sys
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from sprites import PAL, GOODS, WEATHER, BADGE, PANEL, BTN

FONT = os.path.join(HERE, 'raw', 'font', 'ark12', 'ark-pixel-12px-monospaced-zh_hans.ttf')
F12 = ImageFont.truetype(FONT, 12)
F24 = ImageFont.truetype(FONT, 24)
INK, SUB, PAPER = PAL['K'], PAL['N'], PAL['P']
ITEM = {c: m for c, n, m in GOODS}

BDIR = r'E:\GithubRepo\game-buyhouse\art\ios\buildings'
BUILD = {}
for b in json.load(open(os.path.join(BDIR, 'buildings.json'), encoding='utf-8')):
    BUILD[b['code']] = Image.open(os.path.join(BDIR, b['file'])).convert('RGBA')

W, H = 390, 844


def new_screen():
    img = Image.new('RGB', (W, H), PAL['C'])
    return img, ImageDraw.Draw(img)


def nine_slice(img, src, x, y, w, h, c=6):
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


def panel(img, d, x, y, w, h, title=None):
    nine_slice(img, PANEL, x, y, w, h)
    if title:
        tw = F12.getlength(title)
        d.rectangle([x + 10, y - 6, x + 10 + tw + 10, y + 6], fill=PAPER)
        d.text((x + 15, y - 7), title, font=F12, fill=INK)


def button(img, d, x, y, w, h, label, primary=False):
    nine_slice(img, BTN if primary else PANEL, x, y, w, h)
    d.text((x + (w - F12.getlength(label)) / 2, y + (h - 15) / 2), label, font=F12, fill=INK)


def icon(img, im, x, y, scale=2):
    big = im.resize((im.width * scale, im.height * scale), Image.NEAREST)
    img.paste(big, (x, y), big)


def statusbar(img, d, weather='多云', week=12):
    d.rectangle([0, 0, W, 44], fill=PAPER)
    icon(img, WEATHER[weather], 10, 10, 2)
    d.text((48, 13), weather, font=F12, fill=INK)
    wk = f'第 {week} 周'
    d.text((W - 12 - F12.getlength(wk), 13), wk, font=F12, fill=SUB)
    d.line([(0, 44), (W, 44)], fill=INK, width=1)


# ==================== 主界面 ====================
img, d = new_screen()
statusbar(img, d)
y = 54
panel(img, d, 8, y, W - 16, 104, '个人信息')
for i, (k, v) in enumerate([('现 金', '1,234,567 元'), ('存 款', '120 万'), ('余X宝', '8.5 万')]):
    d.text((20, y + 14 + i * 25), k, font=F12, fill=SUB)
    d.text((110, y + 14 + i * 25), v, font=F12, fill=INK)
for i, (lab, val, col) in enumerate([('健康', 82, 'R'), ('声望', 45, 'L')]):
    bx, by = 226, y + 16 + i * 32
    d.text((bx, by - 2), lab, font=F12, fill=SUB)
    d.rectangle([bx + 36, by + 1, bx + 36 + 78, by + 9], fill=PAL['C'], outline=INK)
    d.rectangle([bx + 37, by + 2, bx + 37 + int(76 * val / 100), by + 8], fill=PAL[col])
    d.text((bx + 120, by - 2), str(val), font=F12, fill=INK)

y = 166
panel(img, d, 8, y, W - 16, 184, '出租屋 (37/100)')
room = [('beans', '转基因大豆', 38, 12), ('mask', '防毒面具', 210, 5),
        ('gold', '黄金', 1560, 2), ('car', '汽车', 26000, 1)]
for i, (code, name, buy, num) in enumerate(room):
    ry = y + 16 + i * 42
    icon(img, ITEM[code], 20, ry, 2)
    d.text((60, ry + 2), name, font=F12, fill=INK)
    d.text((60, ry + 19), f'买入价 {buy}', font=F12, fill=SUB)
    q = f'×{num}'
    d.text((W - 26 - F12.getlength(q), ry + 8), q, font=F12, fill=INK)
    if i < 3:
        d.line([(20, ry + 38), (W - 20, ry + 38)], fill=PAL['C'], width=1)

y = 358
panel(img, d, 8, y, W - 16, 184, '市场（本周行情）')
market = [('phone', '手机', 4200, '+12%'), ('computer', '电脑', 9800, '-3%'),
          ('milk', '奶粉', 320, '+8%'), ('moterbike', '摩托车', 15000, '-1%')]
for i, (code, name, price, chg) in enumerate(market):
    ry = y + 16 + i * 42
    icon(img, ITEM[code], 20, ry, 2)
    d.text((60, ry + 2), name, font=F12, fill=INK)
    d.text((60, ry + 19), f'{price} 元', font=F12, fill=SUB)
    d.text((W - 26 - F12.getlength(chg), ry + 8), chg, font=F12, fill=PAL['R'] if chg.startswith('-') else PAL['E'])
    if i < 3:
        d.line([(20, ry + 38), (W - 20, ry + 38)], fill=PAL['C'], width=1)

y = 550
panel(img, d, 8, y, W - 16, 96, '成就 (3/11)')
for i, (name, got) in enumerate([('成为百万富翁', True), ('拥有一所房屋', True), ('度过1年', False)]):
    bx = 20 + (i % 3) * 120
    by = y + 18
    b = BADGE.copy()
    if not got:
        b = Image.merge('RGBA', (b.split()[0], b.split()[1], b.split()[2], b.split()[3].point(lambda v: v // 3)))
    big = b.resize((b.width * 2, b.height * 2), Image.NEAREST)
    img.paste(big, (bx, by), big)
    d.text((bx, by + 36), name, font=F12, fill=INK if got else SUB)

y = 656
panel(img, d, 8, y, W - 16, 96, '操作')
for i, a in enumerate(['医院', '健身房', '银行', '余X宝', '中介', '彩票', '售楼部', '关于']):
    col, row = i % 4, i // 4
    button(img, d, 18 + col * 90, y + 16 + row * 38, 84, 30, a)

button(img, d, 8, H - 58, W - 16, 50, '过一周', primary=True)
img.resize((W * 2, H * 2), Image.NEAREST).save(os.path.join(HERE, 'mock_main.png'))

# ==================== 售楼部 ====================
img, d = new_screen()
d.rectangle([0, 0, W, 44], fill=PAPER)
d.text((12, 13), '← 返回', font=F12, fill=SUB)
title = '售楼部'
d.text(((W - F12.getlength(title)) / 2, 13), title, font=F12, fill=INK)
d.line([(0, 44), (W, 44)], fill=INK, width=1)

cards = [
    ('studio', '单身公寓', '30m²', '40 万'),
    ('oldhouse', '二手旧房', '80m²', '120 万'),
    ('uptown', '高档小区', '108m²', '180 万'),
    ('luxury', '豪华住宅', '180m²', '300 万'),
    ('lakevilla', '湖景别墅', '320m²', '600 万'),
    ('poolvilla', '泳池私宅', '450m²', '1200 万'),
]
CY, CH = 300, 288
for i, (code, name, m2, price) in enumerate(cards):
    col, row = i % 2, i // 2
    cx, cy = 10 + col * 186, 50 + row * CY
    if cy > H:
        break
    panel(img, d, cx, cy, 174, CH)
    d.text((cx + 12, cy + 10), name, font=F12, fill=INK)
    d.text((cx + 12, cy + 28), m2, font=F12, fill=SUB)
    bim = BUILD[code]
    img.paste(bim, (cx + (174 - bim.width) // 2, cy + 200 - bim.height), bim)
    d.text((cx + 12, cy + 206), price, font=F24, fill=PAL['R'])
    button(img, d, cx + 12, cy + 242, 150, 34, '购入')

img.resize((W * 2, H * 2), Image.NEAREST).save(os.path.join(HERE, 'mock_sale.png'))
print('saved mock_main.png / mock_sale.png')

