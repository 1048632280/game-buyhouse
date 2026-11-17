# -*- coding: utf-8 -*-
"""检查 Ark Pixel 12px 对游戏全部文案的覆盖率（缺字在 iOS 上会回退到系统字体）。"""
from PIL import ImageFont

FONT = r'E:\GithubRepo\game-buyhouse\art\_work\raw\font\ark12\ark-pixel-12px-monospaced-zh_hans.ttf'
f = ImageFont.truetype(FONT, 12)

texts = [
    '买房记', '现 金', '存 款', '余X宝', '健 康', '声 望', '出租屋', '市场', '售楼部',
    '医院', '健身房', '银行', '中介', '彩票', '成就', '关于', '重新开始', '过一周',
    '转基因大豆', '防毒面具', '奶粉', '黄金', '手机', '电脑', '摩托车', '汽车',
    '单身公寓', '二手旧房', '高档小区', '豪华住宅', '湖景别墅', '泳池私宅', '一栋小区', '一个楼盘',
    '晴天', '多云', '阴天', '雾', '雷阵雨', '小雨', '中雨', '大雨', '暴雨', '雨加雪',
    '小雪', '中雪', '大雪', '暴雪',
    '成为百万富翁', '成为千万富翁', '成为亿万富翁', '银行存款100万', '余X宝存款100万',
    '拥有一所房屋', '拥有一所豪宅', '购买租房100个', '度过1年(52周)', '度过3年(156周)', '声望出名',
    '游戏结束', '共生存', '周', '退出游戏', '购买成功', '卖出成功', '现金不足', '库存不足',
    '输入数额错误', '要买几个', '要卖几个', '要存取多少', '存款', '取款', '存入', '提现',
    '确定', '取消', '买入价', '价格', '数量', '货物', '库存', '利息', '中奖', '未中奖',
    '开奖中', '重置成功', '关于本软件', '版本', '制作', '已获成就', '成就列表', '空',
]

ref = bytes(f.getmask('\ue000'))
missing = []
for t in texts:
    for ch in t:
        if ch in ' \u3000':
            continue
        m = f.getmask(ch)
        if m.size == (0, 0) or bytes(m) == ref:
            if ch not in missing:
                missing.append(ch)

print('检查字数:', len(set(''.join(texts))))
print('缺字:', ''.join(missing) if missing else '无')
print('缺字数:', len(missing))
