"""Generate Inno Setup wizard images — clean fantasy parchment style."""
from __future__ import annotations

import random
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

OUT = Path(__file__).resolve().parent / "installer_assets"
OUT.mkdir(exist_ok=True)

# warm stone / parchment (readable, not burgundy)
STONE_DARK = (42, 36, 32)
STONE_MID = (68, 58, 48)
STONE_LIGHT = (98, 86, 72)
GOLD = (168, 132, 48)
GOLD_LIGHT = (210, 178, 88)
INK = (28, 22, 18)
CREAM = (236, 224, 196)
ACCENT = (120, 72, 40)


def _font(size: int, bold: bool = False):
    paths = (
        ["C:/Windows/Fonts/timesbd.ttf", "C:/Windows/Fonts/georgiab.ttf"]
        if bold
        else ["C:/Windows/Fonts/times.ttf", "C:/Windows/Fonts/georgia.ttf"]
    )
    for p in paths:
        try:
            return ImageFont.truetype(p, size)
        except OSError:
            pass
    return ImageFont.load_default()


def stone_gradient(size):
    w, h = size
    img = Image.new("RGB", size)
    px = img.load()
    for y in range(h):
        t = y / max(h - 1, 1)
        for x in range(w):
            r = int(STONE_DARK[0] + (STONE_MID[0] - STONE_DARK[0]) * t)
            g = int(STONE_DARK[1] + (STONE_MID[1] - STONE_DARK[1]) * t)
            b = int(STONE_DARK[2] + (STONE_MID[2] - STONE_DARK[2]) * t)
            px[x, y] = (r, g, b)
    return img


def add_grain(img: Image.Image, amt: int = 12) -> Image.Image:
    rng = random.Random(7)
    px = img.load()
    w, h = img.size
    for y in range(0, h, 2):
        for x in range(0, w, 2):
            n = rng.randint(-amt, amt)
            c = px[x, y]
            px[x, y] = tuple(max(0, min(255, v + n)) for v in c)
    return img.filter(ImageFilter.GaussianBlur(0.3))


def frame(draw: ImageDraw.ImageDraw, box, color=GOLD):
    x0, y0, x1, y1 = box
    draw.rectangle(box, outline=color, width=2)
    draw.rectangle((x0 + 4, y0 + 4, x1 - 4, y1 - 4), outline=GOLD_LIGHT, width=1)


def emblem(draw: ImageDraw.ImageDraw, cx: int, cy: int, s: float = 1.0):
    pts = [
        (cx, cy - int(40 * s)),
        (cx + int(30 * s), cy - int(14 * s)),
        (cx + int(26 * s), cy + int(34 * s)),
        (cx, cy + int(46 * s)),
        (cx - int(26 * s), cy + int(34 * s)),
        (cx - int(30 * s), cy - int(14 * s)),
    ]
    draw.polygon(pts, fill=STONE_LIGHT, outline=GOLD, width=2)
    draw.line((cx - int(18 * s), cy - int(22 * s), cx + int(18 * s), cy + int(22 * s)), fill=CREAM, width=2)
    draw.line((cx + int(18 * s), cy - int(22 * s), cx - int(18 * s), cy + int(22 * s)), fill=CREAM, width=2)


def draw_side_panel() -> Image.Image:
    w, h = 164, 314
    img = stone_gradient((w, h))
    img = add_grain(img)
    draw = ImageDraw.Draw(img)
    frame(draw, (6, 6, w - 7, h - 7))

    draw.rectangle((12, 12, w - 13, 54), fill=(52, 44, 38), outline=GOLD, width=1)
    draw.text((w // 2, 24), "SIM TURNS", font=_font(12, True), fill=GOLD_LIGHT, anchor="mm")
    draw.text((w // 2, 40), "AI PATCH", font=_font(12, True), fill=GOLD, anchor="mm")

    emblem(draw, w // 2, h // 2 - 6, 0.9)

    draw.line((20, 118, w - 20, 118), fill=GOLD, width=1)
    draw.text((w // 2, 134), "Heroes of Might", font=_font(8), fill=CREAM, anchor="mm")
    draw.text((w // 2, 148), "& Magic: Olden Era", font=_font(8, True), fill=GOLD_LIGHT, anchor="mm")

    for i, t in enumerate(("AI: realtime ON", "Players: as before")):
        draw.text((w // 2, 170 + i * 16), t, font=_font(7), fill=CREAM, anchor="mm")

    draw.line((20, 208, w - 20, 208), fill=ACCENT, width=1)
    draw.text((w // 2, h - 28), "Imagundi", font=_font(8, True), fill=GOLD_LIGHT, anchor="mm")
    draw.text((w // 2, h - 14), "community patch", font=_font(6), fill=CREAM, anchor="mm")
    return img


def draw_small_icon() -> Image.Image:
    s = 55
    img = stone_gradient((s, s))
    draw = ImageDraw.Draw(img)
    frame(draw, (2, 2, s - 3, s - 3))
    emblem(draw, s // 2, s // 2, 0.38)
    return img


def main():
    side = draw_side_panel()
    small = draw_small_icon()
    side.save(OUT / "wizard_side.bmp", format="BMP")
    small.save(OUT / "wizard_small.bmp", format="BMP")
    sizes = [16, 24, 32, 48, 64, 128, 256]
    icons = [small.resize((n, n), Image.Resampling.LANCZOS) for n in sizes]
    icons[0].save(OUT / "setup_icon.ico", format="ICO", sizes=[(n, n) for n in sizes])
    print("ok:", OUT)


if __name__ == "__main__":
    main()
