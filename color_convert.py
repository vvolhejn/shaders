import re


def hex_to_vec3(hex_code: str):
    # Want something like vec2(0.5, 0.8, 0.3)
    hex_code = hex_code.lstrip("#")
    r = int(hex_code[0:2], 16) / 255.0
    g = int(hex_code[2:4], 16) / 255.0
    b = int(hex_code[4:6], 16) / 255.0
    return f"vec3({r:.2f}, {g:.2f}, {b:.2f})"


def parse_hex(color: str):
    color = color.strip()
    if color.startswith("#"):
        color = color[1:]
    color = color.upper()
    if len(color) == 6 and all(c in "0123456789ABCDEF" for c in color):
        try:
            r = int(color[0:2], 16)
            g = int(color[2:4], 16)
            b = int(color[4:6], 16)
            return (r, g, b)
        except Exception:
            return None
    return None


def parse_rgb(color: str):
    m = re.match(
        r"rgb\s*\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*\)",
        color,
        re.IGNORECASE,
    )
    if m:
        r, g, b = map(int, m.groups())
        if all(0 <= v <= 255 for v in (r, g, b)):
            return (r, g, b)
    return None


def parse_vec3(color: str):
    m = re.match(
        r"vec3\s*\(\s*([0-9.]+)\s*,\s*([0-9.]+)\s*,\s*([0-9.]+)\s*\)",
        color,
        re.IGNORECASE,
    )
    if m:
        r, g, b = map(float, m.groups())
        if all(0.0 <= v <= 1.0 for v in (r, g, b)):
            return (int(round(r * 255)), int(round(g * 255)), int(round(b * 255)))
    return None


def parse_color(color: str):
    for parser in (parse_hex, parse_rgb, parse_vec3):
        result = parser(color)
        if result:
            return result
    return None


def rgb_to_hex(r, g, b):
    return f"#{r:02X}{g:02X}{b:02X}"


def rgb_to_rgb_str(r, g, b):
    return f"rgb({r},{g},{b})"


def rgb_to_vec3(r, g, b):
    return f"vec3({r / 255:.3f}, {g / 255:.3f}, {b / 255:.3f})"


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Convert color formats.")
    parser.add_argument("color", type=str, help="Color, as hex, rgb(...), or vec3()")
    args = parser.parse_args()

    rgb = parse_color(args.color)
    if rgb is None:
        print("Could not parse color.")
    else:
        r, g, b = rgb
        print(rgb_to_hex(r, g, b))
        print(rgb_to_rgb_str(r, g, b))
        print(rgb_to_vec3(r, g, b))
