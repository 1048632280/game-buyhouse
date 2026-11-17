import os
from PIL import Image

TILE = 16
TDIR = r'E:\GithubRepo\game-buyhouse\art\_work\raw\kenney\tiny-city\Tiles'
_cache = {}

def T(i):
    if i not in _cache:
        _cache[i] = Image.open(os.path.join(TDIR, f'tile_{i:04d}.png')).convert('RGBA')
    return _cache[i]

ROOF = {
    'brown': dict(tl=0, t=1, tr=2, l=12, m=13, r=14),
    'blue':  dict(tl=6, t=7, tr=8, l=18, m=19, r=20),
    'brown_band': dict(tl=16, t=16, tr=16, l=12, m=13, r=14),
    'brown_roof': dict(tl=4, t=5, tr=5, l=12, m=13, r=14),
}
WIN = {
    'red':   dict(l=36, m=38, win=40, r=41),
    'brown': dict(l=42, m=44, win=46, r=47),
}
DOOR = {
    'red':   dict(l=48, m=49, d1=52, d2=50, r=53),
    'brown': dict(l=54, m=55, d1=58, d2=56, r=59),
}
GLASS = dict(l=60, b1=61, b2=62, b3=63, r=64)
GLASS_DOOR = dict(l=72, m=73, d=74, m2=76, r=77)


def house(w, roof_rows, roof='brown', win='brown', door='brown', dk='single', win_rows=1):
    h = roof_rows + win_rows + 1
    img = Image.new('RGBA', (w * TILE, h * TILE), (0, 0, 0, 0))
    R = ROOF[roof]
    row = 0
    for rr in range(roof_rows):
        for c in range(w):
            if rr == 0:
                t = R['tl'] if c == 0 else R['tr'] if c == w - 1 else R['t']
            else:
                t = R['l'] if c == 0 else R['r'] if c == w - 1 else R['m']
            img.alpha_composite(T(t), (c * TILE, row * TILE))
        row += 1
    Wd = WIN[win]
    for _ in range(win_rows):
        for c in range(w):
            if c == 0:
                t = Wd['l']
            elif c == w - 1:
                t = Wd['r']
            else:
                t = Wd['win'] if c % 2 == 1 else Wd['m']
            img.alpha_composite(T(t), (c * TILE, row * TILE))
        row += 1
    Dd = DOOR[door]
    dc = max(1, (w - 2) // 2) if dk == 'double' else max(0, (w - 1) // 2)
    for c in range(w):
        if c == 0:
            t = Dd['l']
        elif c == w - 1:
            t = Dd['r']
        elif dk == 'double' and c in (dc, dc + 1):
            t = Dd['d2']
        elif c == dc:
            t = Dd['d1']
        else:
            t = Dd['m']
        img.alpha_composite(T(t), (c * TILE, row * TILE))
    return img


def tower(w, rows):
    h = 1 + rows + 1
    img = Image.new('RGBA', (w * TILE, h * TILE), (0, 0, 0, 0))
    R = ROOF['blue']
    for c in range(w):
        t = R['tl'] if c == 0 else R['tr'] if c == w - 1 else R['t']
        img.alpha_composite(T(t), (c * TILE, 0))
    for r in range(rows):
        for c in range(w):
            if c == 0:
                t = GLASS['l']
            elif c == w - 1:
                t = GLASS['r']
            else:
                t = [GLASS['b1'], GLASS['b2'], GLASS['b3']][c % 3]
            img.alpha_composite(T(t), (c * TILE, (1 + r) * TILE))
    y = (1 + rows) * TILE
    dc = max(1, (w - 2) // 2)
    for c in range(w):
        if c == 0:
            t = GLASS_DOOR['l']
        elif c == w - 1:
            t = GLASS_DOOR['r']
        elif c == dc:
            t = GLASS_DOOR['d']
        else:
            t = GLASS_DOOR['m']
        img.alpha_composite(T(t), (c * TILE, y))
    return img


def with_trees(img, left=0, right=0):
    w = img.width + (left + right) * TILE
    out = Image.new('RGBA', (w, img.height + TILE), (0, 0, 0, 0))
    out.alpha_composite(img, (left * TILE, TILE))
    xs = [67, 68, 70, 71]
    k = 0
    for i in range(left):
        out.alpha_composite(T(xs[k % 2]), (i * TILE, img.height - TILE + TILE))
        k += 1
    for i in range(right):
        out.alpha_composite(T(xs[(k + 1) % 2]), ((left * TILE) + img.width + i * TILE, img.height))
    return out


TIERS = [
    ('单身公寓', house(2, 2, 'brown', 'brown', 'brown', 'single')),
    ('二手旧房', house(2, 2, 'brown_band', 'red', 'red', 'single')),
    ('高档小区', tower(3, 3)),
    ('豪华住宅', house(3, 2, 'brown', 'brown', 'brown', 'double')),
    ('湖景别墅', house(4, 1, 'brown', 'red', 'red', 'double')),
    ('泳池私宅', house(4, 2, 'blue', 'brown', 'brown', 'double')),
    ('一栋小区', tower(4, 4)),
    ('一个楼盘', tower(6, 5)),
]

if __name__ == '__main__':
    scale = 3
    pad = 16
    imgs = [im for _, im in TIERS]
    W = sum(im.width for im in imgs) * scale + pad * (len(imgs) + 1)
    H = max(im.height for im in imgs) * scale + pad * 2
    out = Image.new('RGB', (W, H), (224, 226, 232))
    x = pad
    for im in imgs:
        big = im.resize((im.width * scale, im.height * scale), Image.NEAREST)
        out.paste(big, (x, H - pad - big.height), big)
        x += big.width + pad
    out.save(r'E:\GithubRepo\game-buyhouse\art\_work\test_buildings.png')
    print('saved', out.size)
