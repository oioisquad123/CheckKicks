#!/usr/bin/env python3
"""
Generate CheckKicks App Icon - Premium Sneaker Authentication App
Creates a 1024x1024 icon featuring a stylized sneaker with verification checkmark.
Version 2: Enhanced sneaker design with better proportions and details.
"""

from PIL import Image, ImageDraw
import math

def create_gradient_background(size):
    """Create a deep navy gradient background."""
    img = Image.new('RGB', (size, size))

    # Gradient from top-left (#0F172A) to bottom-right (#1E293B)
    for y in range(size):
        for x in range(size):
            # Calculate position along diagonal
            t = (x + y) / (2 * size)

            # Colors
            r1, g1, b1 = 15, 23, 42      # #0F172A - Deep Navy
            r2, g2, b2 = 30, 41, 59      # #1E293B - Charcoal

            r = int(r1 + (r2 - r1) * t)
            g = int(g1 + (g2 - g1) * t)
            b = int(b1 + (b2 - b1) * t)

            img.putpixel((x, y), (r, g, b))

    return img

def draw_sneaker_v2(draw, offset_x, offset_y, scale):
    """Draw an enhanced stylized sneaker silhouette - side profile view."""
    # Colors
    shoe_white = (248, 250, 252)  # #F8FAFC - Main shoe
    shoe_light = (241, 245, 249)  # #F1F5F9 - Highlights
    shoe_gray = (226, 232, 240)   # #E2E8F0 - Shadows
    sole_gray = (203, 213, 225)   # #CBD5E1 - Sole
    sole_dark = (148, 163, 184)   # #94A3B8 - Sole details
    dark_navy = (15, 23, 42)      # #0F172A - Lace holes

    s = scale

    # === SOLE ===
    sole = [
        (offset_x + int(40*s), offset_y + int(340*s)),
        (offset_x + int(750*s), offset_y + int(340*s)),
        (offset_x + int(770*s), offset_y + int(360*s)),
        (offset_x + int(770*s), offset_y + int(390*s)),
        (offset_x + int(750*s), offset_y + int(420*s)),
        (offset_x + int(70*s), offset_y + int(420*s)),
        (offset_x + int(30*s), offset_y + int(390*s)),
        (offset_x + int(30*s), offset_y + int(360*s)),
    ]
    draw.polygon(sole, fill=sole_gray)

    # Sole tread line
    draw.line([
        (offset_x + int(80*s), offset_y + int(385*s)),
        (offset_x + int(720*s), offset_y + int(385*s))
    ], fill=sole_dark, width=int(4*s))

    # Midsole highlight
    draw.line([
        (offset_x + int(50*s), offset_y + int(355*s)),
        (offset_x + int(760*s), offset_y + int(355*s))
    ], fill=shoe_light, width=int(6*s))

    # === MAIN SHOE BODY ===
    # Heel section
    heel = [
        (offset_x + int(60*s), offset_y + int(340*s)),
        (offset_x + int(60*s), offset_y + int(200*s)),
        (offset_x + int(100*s), offset_y + int(160*s)),
        (offset_x + int(200*s), offset_y + int(140*s)),
        (offset_x + int(200*s), offset_y + int(340*s)),
    ]
    draw.polygon(heel, fill=shoe_gray)

    # Main upper body
    upper = [
        (offset_x + int(60*s), offset_y + int(200*s)),
        (offset_x + int(100*s), offset_y + int(160*s)),
        (offset_x + int(200*s), offset_y + int(140*s)),
        (offset_x + int(350*s), offset_y + int(110*s)),
        (offset_x + int(500*s), offset_y + int(100*s)),
        (offset_x + int(620*s), offset_y + int(110*s)),
        (offset_x + int(700*s), offset_y + int(150*s)),
        (offset_x + int(740*s), offset_y + int(220*s)),
        (offset_x + int(750*s), offset_y + int(300*s)),
        (offset_x + int(750*s), offset_y + int(340*s)),
        (offset_x + int(60*s), offset_y + int(340*s)),
    ]
    draw.polygon(upper, fill=shoe_white)

    # === TOE BOX ===
    toe_box = [
        (offset_x + int(620*s), offset_y + int(120*s)),
        (offset_x + int(700*s), offset_y + int(150*s)),
        (offset_x + int(740*s), offset_y + int(220*s)),
        (offset_x + int(750*s), offset_y + int(300*s)),
        (offset_x + int(750*s), offset_y + int(340*s)),
        (offset_x + int(580*s), offset_y + int(340*s)),
        (offset_x + int(580*s), offset_y + int(200*s)),
    ]
    draw.polygon(toe_box, fill=shoe_light)

    # Toe cap
    toe_cap = [
        (offset_x + int(680*s), offset_y + int(180*s)),
        (offset_x + int(740*s), offset_y + int(220*s)),
        (offset_x + int(750*s), offset_y + int(300*s)),
        (offset_x + int(750*s), offset_y + int(340*s)),
        (offset_x + int(650*s), offset_y + int(340*s)),
        (offset_x + int(650*s), offset_y + int(260*s)),
    ]
    draw.polygon(toe_cap, fill=shoe_gray)

    # === TONGUE ===
    tongue = [
        (offset_x + int(350*s), offset_y + int(110*s)),
        (offset_x + int(400*s), offset_y + int(50*s)),
        (offset_x + int(460*s), offset_y + int(30*s)),
        (offset_x + int(520*s), offset_y + int(35*s)),
        (offset_x + int(560*s), offset_y + int(60*s)),
        (offset_x + int(580*s), offset_y + int(100*s)),
        (offset_x + int(500*s), offset_y + int(100*s)),
    ]
    draw.polygon(tongue, fill=shoe_white)

    # Tongue padding (top edge)
    draw.line([
        (offset_x + int(400*s), offset_y + int(50*s)),
        (offset_x + int(460*s), offset_y + int(30*s)),
        (offset_x + int(520*s), offset_y + int(35*s)),
        (offset_x + int(560*s), offset_y + int(60*s)),
    ], fill=shoe_light, width=int(12*s))

    # === LACE AREA ===
    # Lace panel background
    lace_panel = [
        (offset_x + int(280*s), offset_y + int(130*s)),
        (offset_x + int(560*s), offset_y + int(100*s)),
        (offset_x + int(560*s), offset_y + int(180*s)),
        (offset_x + int(280*s), offset_y + int(200*s)),
    ]
    draw.polygon(lace_panel, fill=shoe_light)

    # Lace holes
    lace_positions = [
        (320, 150), (380, 140), (440, 135), (500, 140), (550, 150)
    ]
    for lx, ly in lace_positions:
        cx = offset_x + int(lx * s)
        cy = offset_y + int(ly * s)
        r = int(12 * s)
        draw.ellipse([cx-r, cy-r, cx+r, cy+r], fill=dark_navy)
        # Inner highlight
        r2 = int(8 * s)
        draw.ellipse([cx-r2, cy-r2+1, cx+r2, cy+r2+1], fill=(30, 41, 59))

    # Laces (cross pattern)
    lace_color = shoe_white
    lace_width = int(4*s)
    draw.line([
        (offset_x + int(330*s), offset_y + int(165*s)),
        (offset_x + int(390*s), offset_y + int(155*s))
    ], fill=lace_color, width=lace_width)
    draw.line([
        (offset_x + int(390*s), offset_y + int(165*s)),
        (offset_x + int(450*s), offset_y + int(150*s))
    ], fill=lace_color, width=lace_width)
    draw.line([
        (offset_x + int(450*s), offset_y + int(160*s)),
        (offset_x + int(510*s), offset_y + int(155*s))
    ], fill=lace_color, width=lace_width)

    # === HEEL COUNTER ===
    heel_counter = [
        (offset_x + int(60*s), offset_y + int(200*s)),
        (offset_x + int(60*s), offset_y + int(340*s)),
        (offset_x + int(150*s), offset_y + int(340*s)),
        (offset_x + int(150*s), offset_y + int(180*s)),
        (offset_x + int(100*s), offset_y + int(160*s)),
    ]
    draw.polygon(heel_counter, fill=shoe_gray)

    # Heel tab
    heel_tab = [
        (offset_x + int(80*s), offset_y + int(150*s)),
        (offset_x + int(140*s), offset_y + int(130*s)),
        (offset_x + int(180*s), offset_y + int(140*s)),
        (offset_x + int(150*s), offset_y + int(170*s)),
        (offset_x + int(100*s), offset_y + int(160*s)),
    ]
    draw.polygon(heel_tab, fill=shoe_light)

    # === SWOOSH-LIKE DETAIL ===
    # A subtle curved accent line (not Nike's swoosh, just a decorative curve)
    for i in range(3):
        offset = i * 2
        draw.arc([
            offset_x + int(200*s) + offset, offset_y + int(200*s) + offset,
            offset_x + int(600*s) - offset, offset_y + int(320*s) - offset
        ], start=180, end=280, fill=sole_dark, width=int(3*s))


def draw_checkmark_badge_v2(draw, center_x, center_y, radius):
    """Draw an enhanced gold verification checkmark badge."""
    # Colors
    dark_navy = (15, 23, 42)       # #0F172A
    gold_light = (229, 197, 71)    # #E5C547
    gold_main = (212, 175, 55)     # #D4AF37
    gold_dark = (184, 150, 46)     # #B8962E

    # Outer glow (subtle)
    for i in range(10, 0, -2):
        glow_radius = radius + i * 2
        alpha = 15 - i
        # Draw slightly larger circles with decreasing opacity
        for angle in range(0, 360, 5):
            x = center_x + int(glow_radius * 0.02 * math.cos(math.radians(angle)))
            y = center_y + int(glow_radius * 0.02 * math.sin(math.radians(angle)))
        draw.ellipse([
            center_x - glow_radius, center_y - glow_radius,
            center_x + glow_radius, center_y + glow_radius
        ], outline=(gold_main[0], gold_main[1], gold_main[2]), width=2)

    # Main circle background
    draw.ellipse([
        center_x - radius, center_y - radius,
        center_x + radius, center_y + radius
    ], fill=dark_navy)

    # Gold ring
    ring_width = int(radius * 0.08)
    draw.ellipse([
        center_x - radius + ring_width, center_y - radius + ring_width,
        center_x + radius - ring_width, center_y + radius - ring_width
    ], outline=gold_main, width=ring_width)

    # Inner subtle glow
    inner_radius = int(radius * 0.75)
    draw.ellipse([
        center_x - inner_radius, center_y - inner_radius,
        center_x + inner_radius, center_y + inner_radius
    ], outline=(gold_main[0], gold_main[1], gold_main[2], 40), width=2)

    # Checkmark
    check_scale = radius / 110

    # Checkmark points - bolder, more confident
    p1 = (center_x - int(50 * check_scale), center_y + int(5 * check_scale))
    p2 = (center_x - int(10 * check_scale), center_y + int(45 * check_scale))
    p3 = (center_x + int(55 * check_scale), center_y - int(40 * check_scale))

    # Draw thick checkmark with gradient effect
    line_width = int(24 * check_scale)

    # Shadow
    shadow_offset = int(3 * check_scale)
    draw.line([
        (p1[0] + shadow_offset, p1[1] + shadow_offset),
        (p2[0] + shadow_offset, p2[1] + shadow_offset)
    ], fill=gold_dark, width=line_width)
    draw.line([
        (p2[0] + shadow_offset, p2[1] + shadow_offset),
        (p3[0] + shadow_offset, p3[1] + shadow_offset)
    ], fill=gold_dark, width=line_width)

    # Main checkmark
    draw.line([p1, p2], fill=gold_main, width=line_width)
    draw.line([p2, p3], fill=gold_main, width=line_width)

    # Highlight
    highlight_offset = int(-2 * check_scale)
    draw.line([
        (p1[0] + highlight_offset, p1[1] + highlight_offset),
        (p2[0] + highlight_offset, p2[1] + highlight_offset)
    ], fill=gold_light, width=int(line_width * 0.4))

    # Round caps
    cap_radius = line_width // 2
    draw.ellipse([p1[0]-cap_radius, p1[1]-cap_radius, p1[0]+cap_radius, p1[1]+cap_radius], fill=gold_main)
    draw.ellipse([p2[0]-cap_radius, p2[1]-cap_radius, p2[0]+cap_radius, p2[1]+cap_radius], fill=gold_main)
    draw.ellipse([p3[0]-cap_radius, p3[1]-cap_radius, p3[0]+cap_radius, p3[1]+cap_radius], fill=gold_main)


def create_checkkicks_icon_v2(size=1024):
    """Create the complete CheckKicks app icon - Version 2."""
    # Create gradient background
    img = create_gradient_background(size)
    draw = ImageDraw.Draw(img)

    # Scale factor
    scale = size / 1024.0

    # Draw sneaker (positioned in upper portion)
    sneaker_offset_x = int(60 * scale)
    sneaker_offset_y = int(230 * scale)
    sneaker_scale = 0.88 * scale
    draw_sneaker_v2(draw, sneaker_offset_x, sneaker_offset_y, sneaker_scale)

    # Draw checkmark badge (positioned in lower-right, overlapping sneaker)
    badge_center_x = int(710 * scale)
    badge_center_y = int(660 * scale)
    badge_radius = int(150 * scale)
    draw_checkmark_badge_v2(draw, badge_center_x, badge_center_y, badge_radius)

    return img


def main():
    print("Creating CheckKicks App Icon v2...")

    # Generate 1024x1024 icon
    icon = create_checkkicks_icon_v2(1024)

    # Save to project directory
    output_path = "/Users/bayuhidayat/Document/Developer_Bayu/Auntentic_check_v2/Auntentic_AI/icon-1024.png"
    icon.save(output_path, "PNG", optimize=True)
    print(f"Saved: {output_path}")

    print("Icon generation complete!")


if __name__ == "__main__":
    main()
