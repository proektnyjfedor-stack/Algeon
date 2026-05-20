#!/usr/bin/env python3
"""Генерация PNG-иконок Algeon (синяя лестница на белом фоне) для web/ — только stdlib."""
from __future__ import annotations

import struct
import zlib
from pathlib import Path

# Синхронно с lib/widgets/app_logo.dart — kAppLogoStairBlue
BLUE = (0x23, 0x88, 0xF2)
WHITE = (0xFF, 0xFF, 0xFF)


def _point_in_poly(x: float, y: float, poly: list[tuple[float, float]]) -> bool:
    inside = False
    n = len(poly)
    for i in range(n):
        x1, y1 = poly[i]
        x2, y2 = poly[(i + 1) % n]
        if (y1 > y) != (y2 > y):
            xin = (x2 - x1) * (y - y1) / (y2 - y1 + 1e-30) + x1
            if x < xin:
                inside = not inside
    return inside


def _stair_polygon(w: float, h: float) -> list[tuple[float, float]]:
    left = w * 0.17
    right = w * 0.83
    bottom = h * 0.82
    top = h * 0.16
    x1 = w * 0.38
    x2 = w * 0.61
    step_height = (bottom - top) / 3
    y1 = bottom - step_height
    y2 = bottom - step_height * 2
    return [
        (left, bottom),
        (right, bottom),
        (right, top),
        (x2, top),
        (x2, y2),
        (x1, y2),
        (x1, y1),
        (left, y1),
    ]


def _write_png_rgb(path: Path, width: int, height: int, pixel_fn) -> None:
    raw = bytearray()
    for y in range(height):
        raw.append(0)  # filter None
        for x in range(width):
            raw.extend(pixel_fn(x, y))

    compressor = zlib.compressobj(9, zlib.DEFLATED, 15)
    compressed = compressor.compress(bytes(raw)) + compressor.flush()

    def chunk(tag: bytes, data: bytes) -> bytes:
        return struct.pack(">I", len(data)) + tag + data + struct.pack(
            ">I", zlib.crc32(tag + data) & 0xFFFFFFFF
        )

    ihdr = struct.pack(
        ">IIBBBBB", width, height, 8, 2, 0, 0, 0
    )  # RGB, no alpha
    png = (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", ihdr)
        + chunk(b"IDAT", compressed)
        + chunk(b"IEND", b"")
    )
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(png)


def render_logo_png(path: Path, size: int) -> None:
    poly = _stair_polygon(float(size), float(size))

    def pixel(x: int, y: int) -> tuple[int, int, int]:
        if _point_in_poly(x + 0.5, y + 0.5, poly):
            return BLUE
        return WHITE

    _write_png_rgb(path, size, size, pixel)


def main() -> None:
    root = Path(__file__).resolve().parent.parent / "web"
    render_logo_png(root / "icons" / "apple-touch-icon.png", 180)
    render_logo_png(root / "apple-touch-icon.png", 180)
    render_logo_png(root / "favicon.png", 32)
    render_logo_png(root / "icons" / "Icon-192.png", 192)
    render_logo_png(root / "icons" / "Icon-512.png", 512)
    # Maskable: логотип в центральной зоне ~64% (безопасная область)
    for name, sz in (("Icon-maskable-192.png", 192), ("Icon-maskable-512.png", 512)):
        inner = int(sz * 0.62)
        ox = (sz - inner) // 2
        oy = (sz - inner) // 2
        poly_full = _stair_polygon(float(inner), float(inner))

        def make_pixel():
            def pixel(x: int, y: int) -> tuple[int, int, int]:
                lx, ly = x - ox, y - oy
                if 0 <= lx < inner and 0 <= ly < inner:
                    if _point_in_poly(lx + 0.5, ly + 0.5, poly_full):
                        return BLUE
                    return WHITE
                return WHITE

            return pixel

        _write_png_rgb(root / "icons" / name, sz, sz, make_pixel())


if __name__ == "__main__":
    main()
    print("OK: web icons regenerated")
