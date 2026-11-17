# -*- coding: utf-8 -*-
"""把游戏用到的全部汉字渲染成一张对照图，肉眼确认缺字（方框）。"""
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
COLS, CELL = 20, 22
rows = (len(chars) + COLS - 1) // COLS
im = Image.new('RGB', (COLS * CELL, rows * (CELL + 14) + 10), (233, 212, 208))
d = ImageDraw.Draw(im)
small = ImageFont.truetype(r'C:\Windows\Fonts\consola.ttf', 8)
for i, ch in enumerate(chars):
    col, row = i % COLS, i // COLS
    x, y = col * CELL + 4, row * (CELL + 14) + 4
    d.text((x, y), ch, font=f, fill=(63, 38, 49))
    d.text((x, y + CELL), f'{ord(ch):04X}', font=small, fill=(120, 100, 105))
im.resize((im.width * 3, im.height * 3), Image.NEAREST).save(
    r'E:\GithubRepo\game-buyhouse\art\_work\coverage_sheet.png')
print('chars', len(chars), 'saved')
