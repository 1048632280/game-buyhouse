# -*- coding: utf-8 -*-
"""可靠的字形覆盖检测：把每个字渲染到固定画布，与缺字符的方框图案逐像素比较。"""
from PIL import Image, ImageDraw, ImageFont

FONT = r'E:\GithubRepo\game-buyhouse\art\_work\raw\font\ark12\ark-pixel-12px-monospaced-zh_hans.ttf'
SIZE = 12
f = ImageFont.truetype(FONT, SIZE)


def bitmap(ch):
    im = Image.new('L', (SIZE * 2, SIZE * 2), 0)
    ImageDraw.Draw(im).text((0, 0), ch, font=f, fill=255)
    return im.tobytes()


ref = bitmap('\ue000')          # 私用区，必缺
ref2 = bitmap('\ue001')
assert ref == ref2, '两个私用区字符渲染不一致，参考图案不可靠'

texts = [
    '买房记', '现 金', '存 款', '余X宝', '健 康', '声 望', '出租屋', '市场', '售楼部',
    '医院', '健身房', '银行', '中介', '彩票', '成就', '关于', '重新开始', '过一周',
    '转基因大豆', '防毒面具', '奶粉', '黄金', '手机', '电脑', '摩托车', '汽车',
    '单身公寓', '二手旧房', '高档小区', '豪华住宅', '湖景别墅', '泳池私宅', '一栋小区', '一个楼盘',
    '晴天', '多云', '阴天', '雾', '雷阵雨', '小雨', '中雨', '大雨', '暴雨', '雨加雪',
    '小雪', '中雪', '大雪', '暴雪',
    '成为百万富翁', '成为千万富翁', '成为亿万富翁', '银行存款100万', '余X宝存款100万',
    '拥有一所房屋', '拥有一所豪宅', '购买租房100个', '度过1年(52周)', '度过3年(156周)', '声望出名',
    '游戏结束', '共生存', '退出游戏', '购买成功', '卖出成功', '现金不足', '库存不足',
    '输入数额错误', '要买几个', '要卖几个', '要存取多少', '存款', '取款', '存入', '提现',
    '确定', '取消', '买入价', '价格', '数量', '货物', '利息', '中奖', '未中奖',
    '开奖中', '重置成功', '关于本软件', '版本', '制作', '已获成就', '成就列表',
]

chars = sorted({c for t in texts for c in t if c not in ' \u3000'})
missing = [c for c in chars if bitmap(c) == ref]
print(f'检测 {len(chars)} 个汉字')
print(f'缺 {len(missing)} 个: {"".join(missing)}')
