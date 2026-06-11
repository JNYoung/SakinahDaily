#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


WIDTH = 1024
HEIGHT = 500
OUTPUT_PATH = Path("build/store-assets/google-play-feature-graphic.png")
ICON_PATH = Path("assets/branding/app_icon.png")


def load_font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    candidates = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "",
        "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/Library/Fonts/Arial.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    ]
    for candidate in candidates:
        if candidate and Path(candidate).exists():
            return ImageFont.truetype(candidate, size)
    return ImageFont.load_default()


def lerp(start: int, end: int, t: float) -> int:
    return int(start + (end - start) * t)


def draw_gradient(draw: ImageDraw.ImageDraw) -> None:
    left = (14, 74, 70)
    right = (238, 226, 197)
    for x in range(WIDTH):
        t = x / (WIDTH - 1)
        color = tuple(lerp(left[index], right[index], t) for index in range(3))
        draw.line([(x, 0), (x, HEIGHT)], fill=color)


def draw_soft_geometry(draw: ImageDraw.ImageDraw) -> None:
    gold = (214, 178, 103)
    teal = (44, 122, 114)
    cream = (250, 247, 237)
    for offset in range(-80, 760, 88):
        draw.line([(offset, HEIGHT), (offset + 260, 0)], fill=(*gold,)[0:3], width=2)
    for radius in (130, 210, 290):
        box = (WIDTH - radius - 40, 42, WIDTH + radius - 40, 42 + radius * 2)
        draw.arc(box, 110, 250, fill=teal, width=3)
    draw.rounded_rectangle((610, 96, 934, 396), radius=44, fill=cream, outline=gold, width=3)
    draw.rounded_rectangle((648, 146, 896, 194), radius=24, fill=(226, 241, 232))
    draw.rounded_rectangle((648, 218, 896, 266), radius=24, fill=(247, 235, 209))
    draw.rounded_rectangle((648, 290, 896, 338), radius=24, fill=(229, 238, 246))


def paste_icon(canvas: Image.Image) -> None:
    if not ICON_PATH.exists():
        return
    icon = Image.open(ICON_PATH).convert("RGBA")
    icon.thumbnail((156, 156), Image.Resampling.LANCZOS)
    shadow = Image.new("RGBA", (180, 180), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.rounded_rectangle((10, 14, 170, 174), radius=42, fill=(0, 0, 0, 42))
    canvas.paste(shadow, (86, 82), shadow)
    canvas.paste(icon, (98, 88), icon)


def draw_text(draw: ImageDraw.ImageDraw) -> None:
    title_font = load_font(66, bold=True)
    subtitle_font = load_font(34)
    small_font = load_font(24)
    chip_font = load_font(20, bold=True)
    deep = (250, 247, 237)
    muted = (225, 239, 232)
    accent = (245, 208, 128)
    ink = (22, 74, 70)

    draw.text((96, 252), "Sakinah Daily", font=title_font, fill=deep)
    draw.text(
        (100, 326),
        "Prayer times and local reminders",
        font=subtitle_font,
        fill=muted,
    )
    draw.text(
        (102, 376),
        "Calm daily worship - local-first privacy",
        font=small_font,
        fill=accent,
    )

    for index, label in enumerate(("Fajr", "Dhuhr", "Asr", "Maghrib", "Isha")):
        x = 642 + (index % 2) * 128
        y = 154 + (index // 2) * 72
        if label == "Isha":
            x = 768
        draw.text((x, y), label, font=chip_font, fill=ink)


def main() -> None:
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    canvas = Image.new("RGB", (WIDTH, HEIGHT), (14, 74, 70))
    draw = ImageDraw.Draw(canvas)
    draw_gradient(draw)
    draw_soft_geometry(draw)
    paste_icon(canvas)
    draw_text(draw)
    canvas.save(OUTPUT_PATH, format="PNG", optimize=True)
    print(f"Generated {OUTPUT_PATH} ({WIDTH}x{HEIGHT}, RGB PNG)")


if __name__ == "__main__":
    main()
