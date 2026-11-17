# -*- coding: utf-8 -*-
"""缺字检测：字体里所有缺字都渲染成同一个 .notdef 方框，按位图分组即可找出。"""
import hashlib
from PIL import Image, ImageDraw, ImageFont

FONT = r'E:\GithubRepo\game-buyhouse\art\_work\raw\font\ark12\ark-pixel-12px-monospaced-zh_hans.ttf'
SIZE = 12
f = ImageFont.truetype(FONT, SIZE)

texts = [
    '买房记现金存款余X宝健康声望出租屋市场售楼部医院健身房银行中介彩票成就关于重新开始过一周',
    '转基因大豆防毒面具奶粉黄金手机电脑摩托车汽车单身公寓二手旧房高档小区豪华住宅湖景别墅泳池私宅',
    '一栋小区一个楼盘晴天多云阴天雾雷阵雨小雨中雨大雨暴雨雨加雪小雪中雪大雪暴雪',
    '成为百万富翁成为千万富翁成为亿万富翁银行存款余宝存款拥有一所房屋拥有一所豪宅购买租房个',
    '度过年周声望出名游戏结束共生存退出游戏购买成功卖出成功现金不足库存不足输入数额错误',
    '要买几个要卖几个要存取多少取款存入提现确定取消买入价价格数量货物利息中奖未中奖开奖中',
    '重置成功关于本软件版本制作已获成就成就列表',
]
chars = [c for c in dict.fromkeys(''.join(texts)) if c not in ' \u3000']


def bm(ch):
    im = Image.new('L', (SIZE * 2, SIZE * 2), 0)
    ImageDraw.Draw(im).text((0, 0), ch, font=f, fill=255)
    return hashlib.md5(im.tobytes()).hexdigest()


groups = {}
for c in chars:
    groups.setdefault(bm(c), []).append(c)

dups = {h: v for h, v in groups.items() if len(v) > 1}
print('位图完全相同的分组:')
for h, v in dups.items():
    print('  ', ''.join(v), ' -> ', ' '.join(f'{ord(c):04X}' for c in v))

# 方框判定：位图只有边框像素（四边亮、中间暗）
def is_tofu(ch):
    im = Image.new('L', (SIZE * 2, SIZE * 2), 0)
    ImageDraw.Draw(im).text((0, 0), ch, font=f, fill=255)
    px = im.load()
    w, h = im.size
    # 找到亮像素包围盒
    xs = [x for x in range(w) for y in range(h) if px[x, y]]
    ys = [y for x in range(w) for y in range(h) if px[x, y]]
    if not xs:
        return True
    x0, x1, y0, y1 = min(xs), max(xs), min(ys), max(ys)
    total = len(xs)
    border = (x1 - x0 + 1) * 2 + (y1 - y0 + 1) * 2 - 4
    return abs(total - border) <= 2

tofu = [c for c in chars if is_tofu(c)]
print('判定为缺字方框:', ''.join(tofu) or '无', f'({len(tofu)})')
