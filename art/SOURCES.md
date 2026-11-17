# 美术素材来源与许可

「买房记」iOS 版（SwiftUI，静态像素风）用到的全部美术与字体。

## 一、外部素材

| 素材 | 来源 | 许可 | 文件 |
|---|---|---|---|
| **房屋 8 档**（等距像素建筑，夏季版正面视角） | [pixel-buildings](https://github.com/hoanglong256/pixel-buildings)（600 栋，GitHub，CC0） | **CC0 1.0** | `ios/BuyHouse/Resources/Assets.xcassets/house_*.imageset` |
| **面板 / 按钮**（像素 9-slice） | 按 Tiny City 调色板自绘 | 本项目自有 | `ui_panel` / `ui_button` |
| **字体** | [方舟像素字体 12px](https://github.com/TakWolf/ark-pixel-font)（zh_hans，2026.11.10） | **SIL OFL 1.1** | `ios/BuyHouse/Resources/Fonts/ArkPixel12.ttf` |

### 房屋选型对照

| 代码 | 游戏名 | 素材目录 |
|---|---|---|
| studio | 单身公寓 | `07-02-flat-fronted-town-house` |
| oldhouse | 二手旧房 | `07-14-crooked-house-over-an-archway` |
| uptown | 高档小区 | `09-01-brick-block` |
| luxury | 豪华住宅 | `09-00-mansard-block` |
| lakevilla | 湖景别墅 | `07-05-canal-house` |
| poolvilla | 泳池私宅 | `09-15-hanging-garden-block` |
| complex | 一栋小区 | `09-04-courtyard-block-in-a-u` |
| estate | 一个楼盘 | `09-08-twin-towers-joined-by-a-bridge` |

## 二、自绘素材（16×16）

Kenney Tiny City 没有现代商品，因此按它统计出的 **33 色调色板**手绘，保证与外部素材同色同描边：

- **货物 8 个**：转基因大豆 / 防毒面具 / 奶粉 / 黄金 / 手机 / 电脑 / 摩托车 / 汽车
- **天气 14 种**：云 / 雨 / 雪 / 雾 四个图层合成（不是 14 张独立图）
- **成就星章**：1 张，未解锁用透明度区分

调色板色值见 `art/_work/sprites.py` 的 `PAL`。

## 三、尺寸与显示约定

| 类型 | 原始尺寸 | 显示 |
|---|---|---|
| 货物 / 天气 / 星章 | 16×16 | 2x = 32pt，最近邻 |
| 面板 / 按钮 | 24×24 | 9-slice，四角 6px 不拉伸 |
| 房屋 | 60×72 ~ 130×169 | 卡片内等比缩放到 130 高 |
| 字体 | 12px 网格 | 字号只用 **12 / 24 / 36**，否则像素会歪 |

## 四、已知取舍

1. **方舟像素 12px 缺 3 个字**：雾、翁、奖。iOS 的 CoreText 会自动回退到系统字体渲染这 3 个字，样式会有轻微差异。若要完全统一，可考虑换 Cubic 11（实测全覆盖）或改写这 3 处文案。
2. 方舟像素 **16px 的构建是残缺的**（大量常用汉字渲染成方框），只能用 12px。
3. 房屋是等距（isometric）风格，与 16×16 正面小图标不是同一透视。二者在界面里扮演不同角色（房屋=大图卡片，货物=列表小图标），目前可以共存；若要更统一，可把货物也改成等距小图。

## 五、生成脚本

都在 `art/_work/`：

| 脚本 | 作用 |
|---|---|
| `sprites.py` | 自绘素材（货物/天气/星章/面板） |
| `export_buildings.py` | 从 pixel-buildings 裁出 8 栋正面图 |
| `export_assets.py` | 导出 PNG 并生成 `Assets.xcassets` 结构 |
| `make_icon.py` | 生成 1024 App 图标 |
| `mock.py` / `style_sheet.py` | 生成界面预演图 |

预览图在 `art/preview/`。
