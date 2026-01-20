#!/usr/bin/env python3
"""
Fix the app icon by removing inner borders and making it full-bleed.
Crops the center content and places it on an edge-to-edge background.
"""

from PIL import Image, ImageDraw, ImageFilter
import os

def remove_inner_border(input_path, output_path):
    """
    Process the icon to remove the inner rounded rectangle border.
    Strategy: Extract the shield area and place on solid edge-to-edge background.
    """
    print(f"Loading: {input_path}")
    img = Image.open(input_path).convert('RGBA')
    width, height = img.size
    print(f"Original size: {width}x{height}")

    # The original icon has visible borders at approximately:
    # - Outer margin: ~50-60px on each side
    # - Inner rounded rectangle border visible

    # Sample the background color from corner (should be the dark navy)
    bg_color = img.getpixel((10, 10))[:3]  # Get RGB from top-left
    print(f"Background color: {bg_color}")

    # Create new image with solid background extending to edges
    new_img = Image.new('RGB', (width, height), bg_color)

    # The inner content (shield) appears to be roughly in center
    # We'll crop a bit to remove the outer frame and then scale up

    # Define crop region to remove the outer border frame
    # The frame appears to be about 50-60px from edges
    crop_margin = 55
    crop_box = (crop_margin, crop_margin, width - crop_margin, height - crop_margin)

    # Crop the center content
    cropped = img.crop(crop_box)
    cropped_width = width - 2 * crop_margin

    # Scale the cropped content back up to fill more space
    # We want the shield to be larger, so scale up by about 1.15x
    scale_factor = 1.12
    new_size = int(cropped_width * scale_factor)
    scaled = cropped.resize((new_size, new_size), Image.Resampling.LANCZOS)

    # Calculate position to center the scaled content
    paste_x = (width - new_size) // 2
    paste_y = (height - new_size) // 2

    # Paste the scaled content onto the solid background
    # Use alpha channel for proper compositing
    if scaled.mode == 'RGBA':
        new_img.paste(scaled, (paste_x, paste_y), scaled)
    else:
        new_img.paste(scaled, (paste_x, paste_y))

    # Clean up any remaining border artifacts at edges
    # Fill the outer edges with solid background color
    draw = ImageDraw.Draw(new_img)

    # Ensure corners and edges are solid background
    edge_fill = 8
    draw.rectangle([0, 0, width, edge_fill], fill=bg_color)  # Top
    draw.rectangle([0, height-edge_fill, width, height], fill=bg_color)  # Bottom
    draw.rectangle([0, 0, edge_fill, height], fill=bg_color)  # Left
    draw.rectangle([width-edge_fill, 0, width, height], fill=bg_color)  # Right

    print(f"Saving to: {output_path}")
    new_img.save(output_path, 'PNG', optimize=True)

    return new_img

def main():
    input_path = "/Users/bayuhidayat/Document/Developer_Bayu/Auntentic_check_v2/ChatGPT Image Jan 2, 2026, 10_23_58 AM.png"
    output_path = "/Users/bayuhidayat/Document/Developer_Bayu/Auntentic_check_v2/Auntentic_AI/app-icon-fullbleed.png"

    if not os.path.exists(input_path):
        print(f"Error: Input file not found: {input_path}")
        return

    result = remove_inner_border(input_path, output_path)

    # Verify output
    print(f"\nOutput dimensions: {result.width}x{result.height}")
    print("Done! Full-bleed icon created.")

if __name__ == "__main__":
    main()
