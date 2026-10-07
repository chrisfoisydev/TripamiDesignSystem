"""Colour math for the Tripami ramps: sRGB, OKLab/OKLCH and WCAG contrast.

The grade scale is the core idea. A colour's grade (0 = white, 1000 = black) is
set by its WCAG luminance alone:

    luminance + 0.05 = 1.05 * BASE ** (-grade / 500)

so the contrast between any two colours depends only on how far apart their
grades are: contrast = BASE ** (gap / 500). With BASE = 4.56, a gap of 500 is
4.56:1 (AA text), 400 is 3.36:1 (AA large text and UI) and 650 is 7.2:1 (AAA).
That holds across hues: orange-200 against navy-700 is as safe as orange-200
against orange-700.
"""
import math

BASE = 4.56  # a hair over 4.5 so 8-bit rounding never drops a 500 gap below AA


def srgb_to_linear(c):
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def linear_to_srgb(c):
    return 12.92 * c if c <= 0.0031308 else 1.055 * c ** (1 / 2.4) - 0.055


def hex_to_rgb(h):
    h = h.lstrip('#')
    return tuple(int(h[i:i + 2], 16) / 255 for i in (0, 2, 4))


def rgb_to_hex(rgb):
    return '#' + ''.join('%02X' % round(max(0, min(1, x)) * 255) for x in rgb)


def luminance(rgb):
    """WCAG 2 relative luminance (with the spec's 0.03928 threshold)."""
    f = lambda c: c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4
    r, g, b = (f(x) for x in rgb)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def contrast(a, b):
    la, lb = luminance(a), luminance(b)
    return (max(la, lb) + 0.05) / (min(la, lb) + 0.05)


def grade_of(hex_color):
    return 500 * math.log(1.05 / (luminance(hex_to_rgb(hex_color)) + 0.05)) / math.log(BASE)


def luminance_for_grade(grade):
    return 1.05 * BASE ** (-grade / 500) - 0.05


def _linear_to_oklab(r, g, b):
    l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
    m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
    s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b
    l, m, s = (math.copysign(abs(x) ** (1 / 3), x) for x in (l, m, s))
    return (0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
            1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
            0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s)


def _oklab_to_linear(L, a, b):
    l = (L + 0.3963377774 * a + 0.2158037573 * b) ** 3
    m = (L - 0.1055613458 * a - 0.0638541728 * b) ** 3
    s = (L - 0.0894841775 * a - 1.2914855480 * b) ** 3
    return (4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
            -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
            -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s)


def hex_to_oklch(h):
    L, a, b = _linear_to_oklab(*(srgb_to_linear(x) for x in hex_to_rgb(h)))
    return L, math.hypot(a, b), math.degrees(math.atan2(b, a)) % 360


def oklch_to_linear(L, C, H):
    return _oklab_to_linear(L, C * math.cos(math.radians(H)), C * math.sin(math.radians(H)))


def in_gamut(lin, eps=1e-6):
    return all(-eps <= x <= 1 + eps for x in lin)
