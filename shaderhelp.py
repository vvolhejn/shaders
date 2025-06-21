def hex_to_vec3(hex_code: str):
    # Want something like vec2(0.5, 0.8, 0.3)
    hex_code = hex_code.lstrip('#')
    r = int(hex_code[0:2], 16) / 255.0
    g = int(hex_code[2:4], 16) / 255.0
    b = int(hex_code[4:6], 16) / 255.0
    return f"vec3({r:.2f}, {g:.2f}, {b:.2f})"

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Convert hex color to vec3 format.")
    parser.add_argument("hex_code", type=str, help="Hex color code (e.g. #FF5733)")
    args = parser.parse_args()
    print(hex_to_vec3(args.hex_code))