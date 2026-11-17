# -*- coding: utf-8 -*-
"""新版主界面布局稿：顶部星章、左右两栏交易、带图标操作区。"""
import os, sys
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from sprites import PAL, GOODS, WEATHER, BADGE, PANEL, BTN, BTN_DOWN, ACTION_ICONS

FONT = os.path.join(HERE, 'raw', 'font', 'ark12', 'ark-pixel-12px-monospaced-zh_hans.ttf')
F12 = ImageFont.truetype(FONT, 12)
F24 = ImageFont.truetype(FONT, 24)
INK, SUB, PAPER, BG, LINE = PAL['K'], PAL['N'], PAL['P'], PAL['C'], PAL['C']
ITEM = {c: m for c, n, m in GOODS}
ACT = {n: m for c, n, m in ACTION_ICONS}

W, H = 390, 844
HPAD = 10
CW = W - HPAD * 2
img = Image.new('RGB', (W, H), BG)
d = ImageDraw.Draw(img)


def panel(x, y, w, h, title=None):
    d.rectangle([x, y, x + w, y + h], fill=PAPER)
    d.rectangle([x, y, x + w, y + h], outline=INK)
    d.rectangle([x + 1, y + 1, x + w - 1, y + h - 1], outline=LINE)
    if title:
        tw = F12.getlength(title)
        d.rectangle([x + 7, y - 8, x + 7 + tw + 26, y + 8], fill=PAPER, outline=INK)
        d.rectangle([x + 11, y - 5, x + 15, y - 1], fill=INK)
        d.text((x + 19, y - 7), title, font=F12, fill=INK)


def button(x, y, w, h, label, icon=None, primary=False):
    d.rectangle([x, y, x + w, y + h], fill=PAL['O'] if primary else PAPER, outline=INK)
    if not primary:
        d.rectangle([x + 1, y + 1, x + w - 1, y + h - 1], outline=LINE)
    tw = F12.getlength(label)
    if icon is not None:
        iw = 16
        total = iw + 5 + tw
        sx = x + (w - total) / 2
        img.paste(icon.resize((16, 16), Image.NEAREST), (int(sx), int(y + (h - 16) / 2)), icon.resize((16, 16), Image.NEAREST))
        d.text((sx + iw + 5, y + (h - 16) / 2), label, font=F12, fill=INK)
    else:
        d.text((x + (w - tw) / 2, y + (h - 16) / 2), label, font=F12, fill=INK)


def dotted(x0, x1, y):
    x = x0
    while x < x1:
        d.point((x, y), fill=LINE)
        d.point((x + 1, y), fill=LINE)
        x += 4


# ---------- 状态条 ----------
d.rectangle([0, 0, W, 44], fill=PAPER)
img.paste(WEATHER['多云'].resize((32, 32), Image.NEAREST), (HPAD + 2, 6), WEATHER['多云'].resize((32, 32), Image.NEAREST))
d.text((HPAD + 40, 15), '多云', font=F12, fill=INK)
wk = '第 12 周'
wkw = F12.getlength(wk)
d.text((W - HPAD - 2 - wkw, 15), wk, font=F12, fill=SUB)
star_w = 16 + 4 + F12.getlength('3/11') + 12
sx = W - HPAD - 2 - wkw - 10 - star_w
d.rectangle([sx, 13, sx + star_w, 31], fill=PAPER, outline=INK)
img.paste(BADGE.resize((16, 16), Image.NEAREST), (int(sx + 6), 14), BADGE.resize((16, 16), Image.NEAREST))
d.text((sx + 26, 15), '3/11', font=F12, fill=INK)
d.line([(0, 44), (W, 44)], fill=INK)

y = 58

# ---------- 个人信息 ----------
PH = 96
panel(HPAD, y, CW, PH, '个人信息')
for i, (k, v) in enumerate([('现 金', '1,234,567 元'), ('存 款', '120 万'), ('余X宝', '8.5 万')]):
    ry = y + 14 + i * 24
    d.text((HPAD + 10, ry), k, font=F12, fill=SUB)
    vw = F12.getlength(v)
    d.text((HPAD + 190 - vw, ry), v, font=F12, fill=INK)
for i, (lab, val, col) in enumerate([('健康', 82, 'R'), ('声望', 45, 'L')]):
    bx, by = 226, y + 16 + i * 30
    d.text((bx, by), lab, font=F12, fill=SUB)
    bw = 66
    d.rectangle([bx + 30, by + 1, bx + 30 + bw, by + 11], fill=LINE, outline=INK)
    d.rectangle([bx + 32, by + 3, bx + 32 + int((bw - 4) * val / 100), by + 9], fill=PAL[col])
    d.text((bx + 30 + bw + 6, by), str(val), font=F12, fill=INK)
y += PH + 12

# ---------- 左右两栏 ----------
COLW = (CW - 8) // 2
room = [('beans', '转基因大豆', 12), ('mask', '防毒面具', 5), ('gold', '黄金', 2)]
market = [('phone', '手机', 4200), ('computer', '电脑', 9800), ('milk', '奶粉', 320)]

BH = 40
PH2 = 22 + BH * 3 + 8
panel(HPAD, y, COLW, PH2, '出租屋 37/100')
for i, (code, name, num) in enumerate(room):
    ry = y + 16 + i * BH
    img.paste(ITEM[code].resize((32, 32), Image.NEAREST), (HPAD + 8, ry + 2), ITEM[code].resize((32, 32), Image.NEAREST))
    d.text((HPAD + 44, ry + 10), name, font=F12, fill=INK)
    q = f'×{num}'
    d.text((HPAD + COLW - 8 - F12.getlength(q), ry + 10), q, font=F12, fill=SUB)
    if i < 2:
        dotted(HPAD + 8, HPAD + COLW - 8, ry + BH - 4)

MX = HPAD + COLW + 8
panel(MX, y, COLW, PH2, '市场')
for i, (code, name, price) in enumerate(market):
    ry = y + 16 + i * BH
    img.paste(ITEM[code].resize((32, 32), Image.NEAREST), (MX + 8, ry + 2), ITEM[code].resize((32, 32), Image.NEAREST))
    d.text((MX + 44, ry + 10), name, font=F12, fill=INK)
    p = str(price)
    d.text((MX + COLW - 8 - F12.getlength(p), ry + 10), p, font=F12, fill=SUB)
    if i < 2:
        dotted(MX + 8, MX + COLW - 8, ry + BH - 4)
y += PH2 + 12

# ---------- 房产 ----------
houses = [('house_uptown', '高档小区'), ('house_lakevilla', '湖景别墅')]
BD = r'E:\GithubRepo\game-buyhouse\ios\BuyHouse\Resources\Assets.xcassets'
PH4 = 112
panel(HPAD, y, CW, PH4, '房产 2/8')
for i, (asset, hname) in enumerate(houses):
    hx = HPAD + 14 + i * 110
    hp = os.path.join(BD, asset + '.imageset', asset + '.png')
    him = Image.open(hp).convert('RGBA')
    s = min(58 / him.height, 1.0)
    hb = him.resize((max(1, int(him.width * s)), max(1, int(him.height * s))), Image.NEAREST)
    img.paste(hb, (hx, y + 76 - hb.height), hb)
    d.text((hx, y + 82), hname, font=F12, fill=INK)
y += PH4 + 12
# ---------- 操作 ----------
acts = ['医院', '健身房', '银行', '余X宝', '中介', '彩票', '售楼部', '关于']
gap = 8
bw = int((CW - 20 - gap * 3) / 4)
PH3 = 20 + 40 * 2 + gap + 8
panel(HPAD, y, CW, PH3, '操作')
for i, a in enumerate(acts):
    col, row = i % 4, i // 4
    bx = HPAD + 10 + col * (bw + gap)
    by = y + 16 + row * (40 + gap)
    button(bx, by, bw, 40, a, icon=ACT[a])
y += PH3 + 12

# ---------- 底部 ----------
bar_y = H - 64
d.rectangle([0, bar_y, W, H], fill=BG)
d.line([(0, bar_y), (W, bar_y)], fill=INK)
d.text((HPAD, bar_y + 12), '健康 82', font=F12, fill=SUB)
d.text((HPAD, bar_y + 32), '库存 37/100', font=F12, fill=SUB)
button(HPAD + 76, bar_y + 9, W - HPAD * 2 - 76, 46, '过一周', primary=True)

img.resize((W * 2, H * 2), Image.NEAREST).save(r'E:\GithubRepo\game-buyhouse\art\preview\05_layout_main_v2.png')
print('saved 05_layout_main_v2.png')



