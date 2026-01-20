#!/usr/bin/env python3
"""
Fix the app icon by aggressively removing inner borders.
Scale up the center content so the inner frame is outside iOS's corner mask.
"""

from PIL import Image, ImageDraw, ImageFilter
import os

def fix_icon_fullbleed(input_path, output_path):
    """
    Aggressively crop and scale to remove inner borders.
    The inner frame should be outside iOS's rounded corner mask (radius ~22%).
    """
    print(f"Loading: {input_path}")
    img = Image.open(input_path).convert('RGB')
    width, height = img.size
    print(f"Original size: {width}x{height}")

    # The background color from the center of the dark area
    bg_color = (10, 12, 26)  # Dark navy

    # Create output image with solid background
    output_size = 1024
    new_img = Image.new('RGB', (output_size, output_size), bg_color)

    # More aggressive crop to remove the entire inner frame
    # The frame appears to be about 50-70px from edges
    crop_margin = 70

    crop_box = (crop_margin, crop_margin, width - crop_margin, height - crop_margin)
    cropped = img.crop(crop_box)
    cropped_size = width - 2 * crop_margin  # Should be ~884

    # Scale up significantly so the shield fills more of the icon
    # iOS icon corner radius is about 22% of width, so anything in outer 22% gets masked
    # We want the shield larger but inner frame outside the mask
    scale_factor = 1.18  # Scale up by 18%
    new_size = int(cropped_size * scale_factor)

    # Resize with high quality
    scaled = cropped.resize((new_size, new_size), Image.Resampling.LANCZOS)

    # Center the scaled content
    paste_x = (output_size - new_size) // 2
    paste_y = (output_size - new_size) // 2

    new_img.paste(scaled, (paste_x, paste_y))

    # Fill any remaining edge artifacts with background color
    draw = ImageDraw.Draw(new_img)

    # Make sure all 4 edges are solid background
    # The paste should have left small strips, fill them
    if paste_x > 0:
        draw.rectangle([0, 0, paste_x, output_size], fill=bg_color)  # Left strip
        draw.rectangle([output_size - paste_x, 0, output_size, output_size], fill=bg_color)  # Right strip
    if paste_y > 0:
        draw.rectangle([0, 0, output_size, paste_y], fill=bg_color)  # Top strip
        draw.rectangle([0, output_size - paste_y, output_size, output_size], fill=bg_color)  # Bottom strip

    print(f"Crop margin: {crop_margin}px, Scale factor: {scale_factor}")
    print(f"Scaled size: {new_size}x{new_size}, Paste offset: ({paste_x}, {paste_y})")
    print(f"Saving to: {output_path}")

    new_img.save(output_path, 'PNG', optimize=True)
    return new_img

def main():
    input_path = "/Users/bayuhidayat/Document/Developer_Bayu/Auntentic_check_v2/ChatGPT Image Jan 2, 2026, 10_23_58 AM.png"
    output_path = "/Users/bayuhidayat/Document/Developer_Bayu/Auntentic_check_v2/Auntentic_AI/app-icon-fullbleed.png"

    if not os.path.exists(input_path):
        print(f"Error: Input file not found: {input_path}")
        return

    result = fix_icon_fullbleed(input_path, output_path)
    print(f"\nOutput: {result.width}x{result.height}")
    print("Done!")

if __name__ == "__main__":
    main()
