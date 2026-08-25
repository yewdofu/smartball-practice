def convert_palette(source_path, output_path, first_color, color_count):
    with open(source_path, "rb") as f:
        palette = f.read()

    start = first_color * 3
    end = start + color_count * 3
    if len(palette) < end:
        raise ValueError(
            f"{source_path} does not contain colors "
            f"{first_color:02X}-{first_color + color_count - 1:02X}"
        )

    converted = bytearray()
    for offset in range(start, end, 3):
        red, green, blue = palette[offset:offset + 3]
        color = (red >> 3) | ((green >> 3) << 5) | ((blue >> 3) << 10)
        converted.extend(color.to_bytes(2, "little"))

    with open(output_path, "wb") as f:
        f.write(converted)
