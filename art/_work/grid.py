import sys, os, glob, re
from PIL import Image, ImageDraw, ImageFont

def load_font(size=10):
    for p in (r'C:\Windows\Fonts\consola.ttf', r'C:\Windows\Fonts\arial.ttf'):
        try:
            return ImageFont.truetype(p, size)
        except Exception:
            pass
    return ImageFont.load_default()

def grid(tile_dir, out, scale=4, cols=12, pad=2, label_h=12):
    files = sorted(glob.glob(os.path.join(tile_dir, '*.png')))
    files = [f for f in files if re.search(r'tile_\d+\.png$', f)] or files
    font = load_font(10)
    cell = 16 * scale + pad * 2
    rows = (len(files) + cols - 1) // cols
    W = cols * cell
    H = rows * (cell + label_h)
    sheet = Image.new('RGB', (W, H), (38, 38, 44))
    d = ImageDraw.Draw(sheet)
    for i, f in enumerate(files):
        r, c = divmod(i, cols)
        x = c * cell + pad
        y = r * (cell + label_h) + pad
        im = Image.open(f).convert('RGBA')
        im = im.resize((im.width * scale, im.height * scale), Image.NEAREST)
        # 棋盘
        for yy in range(y, y + cell - pad * 2, 8):
            for xx in range(x, x + cell - pad * 2, 8):
                if (xx // 8 + yy // 8) % 2 == 0:
                    d.rectangle([xx, yy, xx + 7, yy + 7], fill=(58, 58, 66))
        sheet.paste(im, (x, y), im)
        num = re.search(r'(\d+)', os.path.basename(f))
        d.text((x, y + cell - pad * 2 - 2), num.group(1).lstrip('0') or '0',
               font=font, fill=(255, 220, 120))
    sheet.save(out)
    print(out, sheet.size, len(files), 'tiles')

if __name__ == '__main__':
    grid(sys.argv[1], sys.argv[2], int(sys.argv[3]) if len(sys.argv) > 3 else 4)
