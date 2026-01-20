#!/usr/bin/env python3
"""
Fix icon by painting over the inner border with background color.
"""

from PIL import Image, ImageDraw
import os
import math

def fix_icon_paint_over_border(input_path, output_path):
    """
    Paint over the inner rounded rectangle border with background color.
    """
    print(f"Loading: {input_path}")
    img = Image.open(input_path).convert('RGB')
    width, height = img.size

    # Background color (sample from deep in the corner)
    bg_color = (10, 12, 26)

    draw = ImageDraw.Draw(img)

    # The inner border is a rounded rectangle approximately:
    # - Starting about 45-55 px from edges
    # - With corner radius of about 100-120px
    # - Border thickness about 2-3px

    # We need to paint over this border

    # First, let's paint the outer edges solid
    edge_width = 50  # pixels from edge that should be solid bg

    # Top edge
    draw.rectangle([0, 0, width, edge_width], fill=bg_color)
    # Bottom edge
    draw.rectangle([0, height - edge_width, width, height], fill=bg_color)
    # Left edge
    draw.rectangle([0, 0, edge_width, height], fill=bg_color)
    # Right edge
    draw.rectangle([width - edge_width, 0, width, height], fill=bg_color)

    # Now draw rounded corner fills to blend the edges
    corner_radius = 110  # approximate iOS corner radius scaled

    # Function to draw corner fill
    def fill_corner(cx, cy, r, quadrant):
        """Fill a corner area with background color."""
        for x in range(int(cx - r), int(cx + r) + 1):
            for y in range(int(cy - r), int(cy + r) + 1):
                if 0 <= x < width and 0 <= y < height:
                    # Check if outside the rounded corner
                    dx = x - cx
                    dy = y - cy
                    distance = math.sqrt(dx*dx + dy*dy)

                    # Determine if this pixel should be filled based on quadrant
                    should_fill = False
                    if quadrant == 'tl' and dx <= 0 and dy <= 0:  # top-left
                        should_fill = distance > r
                    elif quadrant == 'tr' and dx >= 0 and dy <= 0:  # top-right
                        should_fill = distance > r
                    elif quadrant == 'bl' and dx <= 0 and dy >= 0:  # bottom-left
                        should_fill = distance > r
                    elif quadrant == 'br' and dx >= 0 and dy >= 0:  # bottom-right
                        should_fill = distance > r

                    if should_fill:
                        img.putpixel((x, y), bg_color)

    # Fill corners
    offset = 50
    fill_corner(offset + corner_radius, offset + corner_radius, corner_radius, 'tl')
    fill_corner(width - offset - corner_radius, offset + corner_radius, corner_radius, 'tr')
    fill_corner(offset + corner_radius, height - offset - corner_radius, corner_radius, 'bl')
    fill_corner(width - offset - corner_radius, height - offset - corner_radius, corner_radius, 'br')

    # Now let's also scale up the content slightly to push the inner border area
    # more towards the edges where it will be masked by iOS

    # Crop inner content (removing outer 30px margin)
    crop_margin = 30
    cropped = img.crop((crop_margin, crop_margin, width - crop_margin, height - crop_margin))

    # Scale up to fill 1024x1024
    scaled = cropped.resize((width, height), Image.Resampling.LANCZOS)

    print(f"Saving to: {output_path}")
    scaled.save(output_path, 'PNG', optimize=True)

    return scaled

def main():
    input_path = "/Users/bayuhidayat/Document/Developer_Bayu/Auntentic_check_v2/ChatGPT Image Jan 2, 2026, 10_23_58 AM.png"
    output_path = "/Users/bayuhidayat/Document/Developer_Bayu/Auntentic_check_v2/Auntentic_AI/app-icon-fullbleed.png"

    if not os.path.exists(input_path):
        print(f"Error: Input file not found: {input_path}")
        return

    result = fix_icon_paint_over_border(input_path, output_path)
    print(f"\nOutput: {result.width}x{result.height}")
    print("Done!")

if __name__ == "__main__":
    main()
