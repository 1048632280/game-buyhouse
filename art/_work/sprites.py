# -*- coding: utf-8 -*-
"""按 Kenney Tiny City 的 33 色调色板，补画缺失的像素素材（16x16）。
用于风格确认：货物 / 天气 / 成就徽章 / 9-slice UI。
"""
import os
from PIL import Image, ImageDraw, ImageFont

# ---- 调色板（取自 Tiny City 全部不透明像素统计） ----
PAL = {
    'K': (0x3F, 0x26, 0x31),  # 描边/深
    'D': (0x7B, 0x4D, 0x3E),  # 深棕
    'B': (0x97, 0x69, 0x5A),  # 棕
    'N': (0x52, 0x60, 0x7C),  # 深蓝灰
    'M': (0x5A, 0x69, 0x88),  # 蓝灰
    'G': (0x8B, 0x9B, 0xB4),  # 中蓝灰
    'C': (0xC0, 0xCB, 0xDC),  # 浅蓝灰
    'P': (0xE9, 0xD4, 0xD0),  # 米白
    'W': (0xFF, 0xFF, 0xFF),
    'R': (0xC3, 0x4B, 0x35),  # 红
    'O': (0xE3, 0x86, 0x28),  # 橙
    'Y': (0xFD, 0xBE, 0x53),  # 黄
    'L': (0x84, 0xC6, 0x69),  # 绿
    'E': (0x47, 0x9F, 0x4A),  # 深绿
    'U': (0x00, 0x9A, 0xDC),  # 蓝
    'S': (0xF2, 0x84, 0x62),  # 珊瑚
}

def sprite(rows, w=16, h=16):
    im = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    px = im.load()
    for y, row in enumerate(rows[:h]):
        assert len(row) <= w, f'row {y} too wide ({len(row)} > {w}): {row!r}'
        for x, ch in enumerate(row):
            if ch in PAL:
                px[x, y] = PAL[ch] + (255,)
    return im

# ---------------- 货物 ----------------
SOYBEAN = sprite([
    '................',
    '.....KKKKKK.....',
    '....KDDDDDDK....',
    '...KKKKKKKKKK...',
    '...KBYBYBYBBK...',
    '..KBBBBBBBBBBK..',
    '..KBBBBBBBBBBK..',
    '..KBBBBBBBBBBK..',
    '..KBBBBBBBBBBK..',
    '..KBBBBBBBBBBK..',
    '..KBBBBBBBBBBK..',
    '..KBBBBBBBBBBK..',
    '..KDBBBBBBBBBD..',
    '..KDDDDDDDDDDK..',
    '...KKKKKKKKKK...',
    '................',
])

MASK = sprite([
    '................',
    '.....KKKKKK.....',
    '...KKGGGGGGKK...',
    '..KGGGGGGGGGGK..',
    '..KGGKKKKKKGGK..',
    '..KGKWWKKWWKGK..',
    '..KGKWWKKWWKGK..',
    '..KGGKKKKKKGGK..',
    '..KGGGGGGGGGGK..',
    '..KGGKKKKKKGGK..',
    '..KGGKDDDDKGGK..',
    '..KGGKDYYDKGGK..',
    '..KGGKDDDDKGGK..',
    '...KKGGGGGGKK...',
    '.....KKKKKK.....',
    '................',
])

MILK = sprite([
    '................',
    '....KKKKKKKK....',
    '...KCCCCCCCCK...',
    '...KGGGGGGGGK...',
    '...KKKKKKKKKK...',
    '...KPPPPPPPPK...',
    '...KPPPPPPPPK...',
    '...KPUUUUUUPK...',
    '...KPUWWWWUPK...',
    '...KPUPWWPUPK...',
    '...KPUPWWPUPK...',
    '...KPUPWWPUPK...',
    '...KPPPPPPPPK...',
    '...KKKKKKKKKK...',
    '................',
    '................',
])

GOLD = sprite([
    '................',
    '......KKKK......',
    '.....KYYYYK.....',
    '....KYYOYYYK....',
    '....KYOOOOYK....',
    '...KKKKKKKKKK...',
    '...KYYYYYYYYK...',
    '..KYYOOOOOYYYK..',
    '..KYOOOOOOOYYK..',
    '.KKKKKKKKKKKKKK.',
    '.KYYYYYYYYYYYYK.',
    'KYYOOOOOOOOOYYYK',
    'KYOOOOOOOOOOOYYK',
    'KKKKKKKKKKKKKKKK',
    '................',
    '................',
])

PHONE = sprite([
    '................',
    '.....KKKKKK.....',
    '.....KMKKMK.....',
    '.....KMCCMK.....',
    '.....KMCCMK.....',
    '.....KMCCMK.....',
    '.....KMCCMK.....',
    '.....KMCCMK.....',
    '.....KMCCMK.....',
    '.....KMCCMK.....',
    '.....KMKKMK.....',
    '.....KKKKKK.....',
    '................',
    '................',
    '................',
    '................',
])

COMPUTER = sprite([
    '................',
    '.KKKKKKKKKKKKKK.',
    '.KMMMMMMMMMMMMK.',
    '.KMCCCCCCCCCCMK.',
    '.KMCCCCCCCCCCMK.',
    '.KMCCCCCCCCCCMK.',
    '.KMCCCCCCCCCCMK.',
    '.KMCCCCCCCCCCMK.',
    '.KMMMMMMMMMMMMK.',
    '.KKKKKKKKKKKKKK.',
    '......KKKK......',
    '......KMMK......',
    '....KKKKKKKK....',
    '....KMMMMMMK....',
    '....KKKKKKKK....',
    '................',
])

def _make_bike():
    """侧视摩托：两个 6x6 轮子 + 车身 + 车把。"""
    im = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    px = im.load()
    K, M, N, G = PAL['K'] + (255,), PAL['M'] + (255,), PAL['N'] + (255,), PAL['G'] + (255,)
    for ox in (1, 9):
        for y in range(9, 15):
            for x in range(ox, ox + 6):
                edge = y in (9, 14) or x in (ox, ox + 5)
                px[x, y] = K if edge else N
    for x in range(4, 12):
        px[x, 9] = px[x, 8] = M
    for x in range(4, 9):
        px[x, 7] = M
    for x in range(5, 10):
        px[x, 6] = N
    for y in range(4, 8):
        px[11, y] = K
        px[12, y] = M
    for x in range(10, 14):
        px[x, 4] = K
    px[3, 8] = px[3, 9] = K
    px[12, 8] = px[12, 9] = M
    return im


MOTORBIKE = _make_bike()

CAR = sprite([
    '................',
    '................',
    '.....KKKKKK.....',
    '...KKMMMMMMKK...',
    '..KMCCCCCCCCMK..',
    '..KMCCCCCCCCMK..',
    '.KKKKKKKKKKKKKK.',
    '.KMMMMMMMMMMMMK.',
    '.KMCCCCCCCCCCMK.',
    '.KMMMMMMMMMMMMK.',
    '.KKKKKKKKKKKKKK.',
    '..KKKK....KKKK..',
    '..KMMK....KMMK..',
    '..KKKK....KKKK..',
    '................',
    '................',
])

# ---------------- 天气基础件 ----------------
SUN = sprite([
    '................',
    '.......YY.......',
    '..Y....YY....Y..',
    '...Y..YYYY..Y...',
    '....YYYYYYYY....',
    '...YYYYYYYYYY...',
    '..YYYYYYYYYYYY..',
    'YYY.YYYYYYYY.YYY',
    '..YYYYYYYYYYYY..',
    '...YYYYYYYYYY...',
    '....YYYYYYYY....',
    '...Y..YYYY..Y...',
    '..Y....YY....Y..',
    '.......YY.......',
    '................',
    '................',
])

CLOUD = sprite([
    '................',
    '................',
    '......KKKK......',
    '....KKWWWWKK....',
    '...KWWWWWWWWK...',
    '..KWWWWWWWWWWK..',
    '.KWWWWWWWWWWWWK.',
    '.KWWWWWWWWWWWWK.',
    '.KCCCCCCCCCCCCK.',
    '.KKKKKKKKKKKKKK.',
    '................',
    '................',
    '................',
    '................',
    '................',
    '................',
])

CLOUD_DARK = sprite([
    '................',
    '................',
    '......KKKK......',
    '....KKGGGGKK....',
    '...KGGGGGGGGK...',
    '..KGGGGGGGGGGK..',
    '.KGGGGGGGGGGGGK.',
    '.KGGGGGGGGGGGGK.',
    '.KMMMMMMMMMMMMK.',
    '.KKKKKKKKKKKKKK.',
    '................',
    '................',
    '................',
    '................',
    '................',
    '................',
])

def layer(base, over, y=0):
    out = base.copy()
    out.alpha_composite(over, (0, y))
    return out

def drops(n, color='U'):
    im = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    xs = {1: [7], 2: [5, 9], 3: [4, 7, 10], 4: [3, 6, 9, 12], 5: [2, 5, 8, 11, 14]}[n]
    for x in xs:
        d.rectangle([x, 11, x + 1, 14], fill=PAL[color] + (255,))
    return im

def flakes(n):
    im = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    xs = {1: [7], 2: [5, 9], 3: [3, 7, 11]}[n]
    for x in xs:
        d.rectangle([x, 11, x, 12], fill=PAL['G'] + (255,))
        d.rectangle([x - 1, 12, x + 1, 12], fill=PAL['G'] + (255,))
        d.rectangle([x, 13, x, 13], fill=PAL['G'] + (255,))
    return im

def foglines():
    im = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    for y, (a, b) in zip((10, 12, 14), ((3, 12), (4, 11), (3, 10))):
        d.rectangle([a, y, b, y], fill=PAL['C'] + (255,))
    return im

def bolt():
    im = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    pts = [(10, 10), (8, 13), (10, 13), (8, 15), (12, 12), (10, 12), (12, 10)]
    d.polygon(pts, fill=PAL['Y'] + (255,))
    return im

WEATHER = {
    '晴天': SUN,
    '多云': layer(SUN, CLOUD, 3),
    '阴天': CLOUD,
    '雾': layer(CLOUD, foglines()),
    '小雨': layer(CLOUD, drops(2)),
    '中雨': layer(CLOUD, drops(3)),
    '大雨': layer(CLOUD_DARK, drops(4)),
    '暴雨': layer(CLOUD_DARK, drops(5)),
    '雷阵雨': layer(layer(CLOUD_DARK, drops(3)), bolt()),
    '雨加雪': layer(layer(CLOUD, drops(2)), flakes(1)),
    '小雪': layer(CLOUD, flakes(1)),
    '中雪': layer(CLOUD, flakes(2)),
    '大雪': layer(CLOUD_DARK, flakes(3)),
    '暴雪': layer(CLOUD_DARK, flakes(3)),
}

# 云的图层顺序修正：多云应是云在太阳上
WEATHER['多云'] = layer(SUN, CLOUD, 3)

# ---------------- 成就徽章 ----------------
BADGE = sprite([
    '',
    '.......KK',
    '......KYYK',
    '......KYYK',
    '.....KYYYYK',
    'KKKKKKYYYYYKKKK',
    'KYYYYYYYYYYYYYY',
    '.KYYYYYYYYYYYYK',
    '..KYYYYYYYYYYK',
    '...KYYYYYYYYK',
    '....KYYYYYYK',
    '...KYYYYYYYYK',
    '..KYYYK..KYYYK',
    '..KYYK....KYYK',
    '..KKK......KKK',
])

# ---------------- 9-slice UI ----------------
def nine_slice(fill='P', edge='C', dark='K', size=(24, 24)):
    im = Image.new('RGBA', size, (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    w, h = size
    d.rectangle([0, 0, w - 1, h - 1], fill=PAL[fill] + (255,))
    d.rectangle([0, 0, w - 1, h - 1], outline=PAL[dark] + (255,))
    d.rectangle([1, 1, w - 2, h - 2], outline=PAL[edge] + (255,))
    return im

PANEL = nine_slice('P', 'C', 'K', (24, 24))
BTN = nine_slice('O', 'Y', 'K', (24, 24))
BTN_DOWN = nine_slice('D', 'B', 'K', (24, 24))

# ---------------- 操作按钮图标 ----------------
HOSPITAL = sprite([
    '',
    '......KKKK',
    '......KRRK',
    '......KRRK',
    '...KKKKRRKKKK',
    '...KRRRRRRRRK',
    '...KRRRRRRRRK',
    '...KKKKRRKKKK',
    '......KRRK',
    '......KRRK',
    '......KKKK',
])

GYM = sprite([
    '',
    '',
    '',
    '..KK........KK',
    '.KMMK......KMMK',
    '.KMMKKKKKKKKMMK',
    '.KMMMMMMMMMMMMK',
    '.KMMKKKKKKKKMMK',
    '.KMMK......KMMK',
    '..KK........KK',
])

BANK = sprite([
    '',
    '......KKKK',
    '.....KYYYYK',
    '....KYYYYYYK',
    '...KYYYYYYYYK',
    '..KKKKKKKKKKKK',
    '..KGGKKGGKKGGK',
    '..KGGKKGGKKGGK',
    '..KGGKKGGKKGGK',
    '..KKKKKKKKKKKK',
])

ALIPAY = sprite([
    '',
    '......KKKK',
    '.....KDDDDK',
    '....KDDDDDDK',
    '...KDYYDDYYDK',
    '...KDYDDDDYDK',
    '...KDDDYYDDDK',
    '..KDDDDDDDDDDK',
    '..KDDDDDDDDDDK',
    '...KDDDDDDDDK',
    '....KKKKKKKK',
])

AGENT = sprite([
    '',
    '...KKKK',
    '..KYYYYK',
    '..KY..YK',
    '..KYYYYK',
    '...KYYK',
    '....KYK',
    '....KYK',
    '....KYKK',
    '....KYK.KK',
    '....KYK..KK',
    '....KKK',
])

LOTTERY = sprite([
    '',
    '.KKKKKKKKKKKK',
    '.KPPPPPPPPPPK',
    '.KPKPPPKPPKPK',
    '.KPPKKKKKKPPK',
    '.KPPPKRRKPPPK',
    '.KPPKKKKKKPPK',
    '.KPKPPPKPPKPK',
    '.KPPPPPPPPPPK',
    '.KKKKKKKKKKKK',
])

SALES = sprite([
    '',
    '.......KK',
    '......KRRK',
    '.....KRRRRK',
    '....KRRRRRRK',
    '...KKKKKKKKKK',
    '...KPPPPPPPPK',
    '...KPPKKKKPPK',
    '...KPPKPPKPPK',
    '...KPPKKKKPPK',
    '...KPPPKKPPPK',
    '...KKKKKKKKKK',
])

ABOUT = sprite([
    '',
    '.....KKKKKK',
    '...KKCCCCCCKK',
    '..KCCCCCCCCCCK',
    '..KCCCKKKKCCCK',
    '..KCCCKKKKCCCK',
    '..KCCCCCCCCCCK',
    '..KCCCCKKCCCCK',
    '..KCCCCKKCCCCK',
    '..KCCCCCCCCCCK',
    '..KCCCCKKCCCCK',
    '...KKCCCCCCKK',
])

ACTION_ICONS = [
    ('hospital', '医院', HOSPITAL),
    ('gym', '健身房', GYM),
    ('bank', '银行', BANK),
    ('alipay', '余X宝', ALIPAY),
    ('agent', '中介', AGENT),
    ('lottery', '彩票', LOTTERY),
    ('sales', '售楼部', SALES),
    ('about', '关于', ABOUT),
]

GOODS = [
    ('beans', '转基因大豆', SOYBEAN),
    ('mask', '防毒面具', MASK),
    ('milk', '奶粉', MILK),
    ('gold', '黄金', GOLD),
    ('phone', '手机', PHONE),
    ('computer', '电脑', COMPUTER),
    ('moterbike', '摩托车', MOTORBIKE),
    ('car', '汽车', CAR),
]

if __name__ == '__main__':
    out_dir = r'E:\GithubRepo\game-buyhouse\art\_work\out'
    os.makedirs(out_dir, exist_ok=True)
    for code, name, im in GOODS:
        im.save(os.path.join(out_dir, f'item_{code}.png'))
    for name, im in WEATHER.items():
        im.save(os.path.join(out_dir, f'weather_{name}.png'))
    BADGE.save(os.path.join(out_dir, 'badge.png'))
    PANEL.save(os.path.join(out_dir, 'panel.png'))
    BTN.save(os.path.join(out_dir, 'btn.png'))
    print('written', len(GOODS) + len(WEATHER) + 4, 'files to', out_dir)


