import glob, collections
from PIL import Image

files = glob.glob(r'E:\GithubRepo\game-buyhouse\art\_work\raw\kenney\tiny-city\Tiles\*.png')
cnt = collections.Counter()
for f in files:
    im = Image.open(f).convert('RGBA')
    for px in im.getdata():
        if px[3] > 200:
            cnt[px[:3]] += 1

print('unique opaque colors:', len(cnt))
pal = [c for c, n in cnt.most_common(40)]
for i, c in enumerate(pal):
    print(f'{i:2d}  #{c[0]:02X}{c[1]:02X}{c[2]:02X}  {cnt[c]}')
print()
print('swatch order:', [f'#{c[0]:02X}{c[1]:02X}{c[2]:02X}' for c in pal])
