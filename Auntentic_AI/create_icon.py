#!/usr/bin/env python3
"""
Create a full-bleed app icon with gold shield and checkmark.
No borders, no rounded corners - iOS adds those automatically.
"""

from PIL import Image, ImageDraw, ImageFilter
import math

def create_fullbleed_icon(size=1024):
    """Create a full-bleed app icon."""

    # Colors
    bg_dark = (10, 14, 26)  # #0a0e1a - Dark navy
    gold_bright = (255, 215, 0)  # #ffd700
    gold_dark = (184, 134, 11)  # #b8860b
    gold_mid = (218, 165, 32)  # #daa520
    shield_inner = (13, 17, 23)  # Dark interior

    # Create main image with dark background - FULL BLEED, no borders
    img = Image.new('RGB', (size, size), bg_dark)
    draw = ImageDraw.Draw(img)

    # Add subtle gradient effect to background
    for y in range(size):
        for x in range(size):
            # Diagonal gradient
            factor = (x + y) / (2 * size)
            r = int(bg_dark[0] + (18 - bg_dark[0]) * factor * 0.3)
            g = int(bg_dark[1] + (24 - bg_dark[1]) * factor * 0.3)
            b = int(bg_dark[2] + (41 - bg_dark[2]) * factor * 0.3)
            img.putpixel((x, y), (r, g, b))

    draw = ImageDraw.Draw(img)

    # Shield dimensions - LARGER to fill more space
    center_x = size // 2
    center_y = int(size * 0.47)  # Slightly above center
    shield_width = int(size * 0.62)  # Larger shield
    shield_height = int(size * 0.72)
    border_width = int(size * 0.04)  # Gold border thickness

    def draw_shield(cx, cy, width, height, color, draw_obj):
        """Draw a shield shape."""
        # Shield path points
        top_y = cy - height // 2
        bottom_y = cy + height // 2
        left_x = cx - width // 2
        right_x = cx + width // 2

        # Control points for curves
        shoulder_y = top_y + height * 0.15
        waist_y = cy + height * 0.1

        points = []
        steps = 100

        # Top curve (left to right)
        for i in range(steps + 1):
            t = i / steps
            x = left_x + (right_x - left_x) * t
            # Gentle curve at top
            curve = math.sin(t * math.pi) * (height * 0.02)
            y = top_y + curve
            points.append((x, y))

        # Right side curve down
        for i in range(1, steps + 1):
            t = i / steps
            # Curve inward as we go down
            x = right_x - (right_x - cx) * (t ** 1.5)
            y = top_y + (bottom_y - top_y) * t
            points.append((x, y))

        # Bottom point
        points.append((cx, bottom_y))

        # Left side curve up
        for i in range(1, steps):
            t = 1 - (i / steps)
            x = left_x + (cx - left_x) * ((1-t) ** 1.5)
            y = top_y + (bottom_y - top_y) * (1-t)
            points.append((x, y))

        draw_obj.polygon(points, fill=color)
        return points

    # Create glow layer
    glow_img = Image.new('RGB', (size, size), bg_dark)
    glow_draw = ImageDraw.Draw(glow_img)

    # Draw gold glow behind shield
    for i in range(30, 0, -1):
        alpha = int(255 * (i / 30) * 0.15)
        glow_color = (
            int(gold_mid[0] * 0.3),
            int(gold_mid[1] * 0.3),
            int(gold_mid[2] * 0.3)
        )
        draw_shield(center_x, center_y,
                   shield_width + i*4, shield_height + i*4,
                   glow_color, glow_draw)

    # Blur the glow
    glow_img = glow_img.filter(ImageFilter.GaussianBlur(radius=20))

    # Composite glow onto main image
    img = Image.blend(img, glow_img, 0.5)
    draw = ImageDraw.Draw(img)

    # Draw outer shield (gold border)
    # Create gradient effect by drawing multiple layers
    for i in range(border_width, 0, -1):
        # Gradient from bright gold to darker gold
        t = i / border_width
        color = (
            int(gold_bright[0] * t + gold_dark[0] * (1-t)),
            int(gold_bright[1] * t + gold_dark[1] * (1-t)),
            int(gold_bright[2] * t + gold_dark[2] * (1-t))
        )
        draw_shield(center_x, center_y,
                   shield_width - (border_width - i) * 2,
                   shield_height - (border_width - i) * 2,
                   color, draw)

    # Draw inner shield (dark fill)
    inner_width = shield_width - border_width * 2.5
    inner_height = shield_height - border_width * 2.5
    draw_shield(center_x, center_y, inner_width, inner_height, shield_inner, draw)

    # Draw checkmark
    check_color = gold_bright
    stroke_width = int(size * 0.055)  # Thicker checkmark

    # Checkmark points (relative to center)
    check_start = (center_x - int(size * 0.12), center_y + int(size * 0.02))
    check_mid = (center_x - int(size * 0.02), center_y + int(size * 0.12))
    check_end = (center_x + int(size * 0.17), center_y - int(size * 0.10))

    # Draw thick checkmark with rounded ends
    for offset in range(-stroke_width//2, stroke_width//2 + 1):
        for offset2 in range(-stroke_width//2, stroke_width//2 + 1):
            if offset*offset + offset2*offset2 <= (stroke_width//2)**2:
                draw.line([
                    (check_start[0] + offset, check_start[1] + offset2),
                    (check_mid[0] + offset, check_mid[1] + offset2)
                ], fill=check_color, width=3)
                draw.line([
                    (check_mid[0] + offset, check_mid[1] + offset2),
                    (check_end[0] + offset, check_end[1] + offset2)
                ], fill=check_color, width=3)

    # Draw proper thick lines
    draw.line([check_start, check_mid], fill=gold_bright, width=stroke_width)
    draw.line([check_mid, check_end], fill=gold_bright, width=stroke_width)

    # Add rounded caps
    radius = stroke_width // 2
    draw.ellipse([check_start[0]-radius, check_start[1]-radius,
                  check_start[0]+radius, check_start[1]+radius], fill=gold_bright)
    draw.ellipse([check_mid[0]-radius, check_mid[1]-radius,
                  check_mid[0]+radius, check_mid[1]+radius], fill=gold_bright)
    draw.ellipse([check_end[0]-radius, check_end[1]-radius,
                  check_end[0]+radius, check_end[1]+radius], fill=gold_bright)

    # Add subtle sparkle highlights
    sparkles = [
        (center_x - int(size * 0.22), center_y - int(size * 0.20), 4),
        (center_x + int(size * 0.20), center_y - int(size * 0.08), 3),
        (center_x + int(size * 0.14), center_y + int(size * 0.16), 2),
    ]

    for sx, sy, sr in sparkles:
        for i in range(sr, 0, -1):
            alpha = int(255 * (i / sr))
            sparkle_color = (255, 255, min(255, 102 + alpha))
            draw.ellipse([sx-i, sy-i, sx+i, sy+i], fill=sparkle_color)

    # Add subtle reflection at bottom
    reflection_y = int(size * 0.88)
    for i in range(20):
        alpha = 0.03 * (1 - i/20)
        rx = center_x
        ry = reflection_y + i
        rw = int(size * 0.2) - i * 3
        if rw > 0:
            reflection_color = (
                int(gold_mid[0] * alpha),
                int(gold_mid[1] * alpha),
                int(gold_mid[2] * alpha)
            )
            draw.ellipse([rx-rw, ry-3, rx+rw, ry+3], fill=reflection_color)

    return img

if __name__ == "__main__":
    print("Creating full-bleed app icon (1024x1024)...")
    icon = create_fullbleed_icon(1024)

    output_path = "/Users/bayuhidayat/Document/Developer_Bayu/Auntentic_check_v2/Auntentic_AI/app-icon-1024.png"
    icon.save(output_path, "PNG", optimize=True)
    print(f"Saved to: {output_path}")

    # Verify dimensions
    from PIL import Image as PILImage
    verify = PILImage.open(output_path)
    print(f"Dimensions: {verify.width}x{verify.height}")
    print("Done!")
