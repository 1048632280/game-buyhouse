# -*- coding: utf-8 -*-
"""把素材导出成 iOS 资源：art/ios/*.png + Assets.xcassets 结构。"""
import json, os, shutil, sys
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from sprites import GOODS, WEATHER, BADGE, PANEL, BTN, BTN_DOWN, ACTION_ICONS

IOS = r'E:\GithubRepo\game-buyhouse\ios\BuyHouse\Resources'
XC = os.path.join(IOS, 'Assets.xcassets')
PNG = os.path.join(IOS, 'png')

WEATHER_KEY = {
    '晴天': 'sunny', '多云': 'partly_cloudy', '阴天': 'overcast', '雾': 'fog',
    '雷阵雨': 'thunderstorm', '小雨': 'light_rain', '中雨': 'moderate_rain',
    '大雨': 'heavy_rain', '暴雨': 'rainstorm', '雨加雪': 'sleet',
    '小雪': 'light_snow', '中雪': 'moderate_snow', '大雪': 'heavy_snow', '暴雪': 'blizzard',
}


def write_imageset(name, img):
    d = os.path.join(XC, f'{name}.imageset')
    os.makedirs(d, exist_ok=True)
    p = os.path.join(d, f'{name}.png')
    img.save(p)
    with open(os.path.join(d, 'Contents.json'), 'w', encoding='utf-8') as f:
        json.dump({
            'images': [{'filename': f'{name}.png', 'idiom': 'universal', 'scale': '1x'}],
            'info': {'author': 'xcode', 'version': 1},
        }, f, indent=2)


def main():
    os.makedirs(PNG, exist_ok=True)
    os.makedirs(XC, exist_ok=True)
    with open(os.path.join(XC, 'Contents.json'), 'w', encoding='utf-8') as f:
        json.dump({'info': {'author': 'xcode', 'version': 1}}, f, indent=2)

    manifest = []

    def emit(name, img):
        img.save(os.path.join(PNG, f'{name}.png'))
        write_imageset(name, img)
        manifest.append({'name': name, 'size': list(img.size)})

    for code, cname, im in GOODS:
        emit(f'item_{code}', im)
    for cname, im in WEATHER.items():
        emit(f'weather_{WEATHER_KEY[cname]}', im)
    emit('star', BADGE)
    emit('ui_panel', PANEL)
    emit('ui_button', BTN)
    emit('ui_button_pressed', BTN_DOWN)
    for code, cname, im in ACTION_ICONS:
        emit(f'act_{code}', im)

    # 房屋（已导出的 png）
    bdir = r'E:\GithubRepo\game-buyhouse\art\ios\buildings'
    for b in json.load(open(os.path.join(bdir, 'buildings.json'), encoding='utf-8')):
        im = Image.open(os.path.join(bdir, b['file'])).convert('RGBA')
        emit(f"house_{b['code']}", im)

    # 字体
    fdir = os.path.join(IOS, 'Fonts')
    os.makedirs(fdir, exist_ok=True)
    shutil.copy(os.path.join(HERE, 'raw', 'font', 'ark12', 'ark-pixel-12px-monospaced-zh_hans.ttf'),
                os.path.join(fdir, 'ArkPixel12.ttf'))
    shutil.copy(os.path.join(HERE, 'raw', 'font', 'ark12', 'OFL.txt'),
                os.path.join(fdir, 'ArkPixel12-OFL.txt'))

    with open(os.path.join(PNG, 'manifest.json'), 'w', encoding='utf-8') as f:
        json.dump(manifest, f, ensure_ascii=False, indent=1)
    print('assets:', len(manifest), '->', XC)


if __name__ == '__main__':
    main()
