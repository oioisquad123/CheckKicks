#!/usr/bin/env python3
"""
Aggressively crop and scale to completely remove the inner border.
iOS masks corners at ~22% radius, so push the border outside that zone.
"""

from PIL import Image
import os

def fix_icon_aggressive(input_path, output_path):
    """
    Very aggressive crop and scale to eliminate inner border completely.
    """
    print(f"Loading: {input_path}")
    img = Image.open(input_path).convert('RGB')
    original_size = img.size[0]

    # The inner border is approximately 50px from each edge
    # iOS corner radius is about 22% = 225px on a 1024 icon
    # To hide the border in corners, we need to push it outside ~225px zone

    # Strategy: Crop 100px from each edge and scale up
    # This will make the content fill more of the icon
    # and push the remaining border artifacts outside iOS mask

    crop_amount = 95  # Crop 95px from each edge

    crop_box = (crop_amount, crop_amount,
                original_size - crop_amount, original_size - crop_amount)

    cropped = img.crop(crop_box)
    cropped_size = original_size - 2 * crop_amount  # 834x834

    print(f"Cropped from {original_size} to {cropped_size}")

    # Scale back up to 1024x1024
    scaled = cropped.resize((1024, 1024), Image.Resampling.LANCZOS)

    print(f"Scaled back to 1024x1024")
    print(f"Saving to: {output_path}")

    scaled.save(output_path, 'PNG', optimize=True)
    return scaled

def main():
    input_path = "/Users/bayuhidayat/Document/Developer_Bayu/Auntentic_check_v2/ChatGPT Image Jan 2, 2026, 10_23_58 AM.png"
    output_path = "/Users/bayuhidayat/Document/Developer_Bayu/Auntentic_check_v2/Auntentic_AI/app-icon-fullbleed.png"

    if not os.path.exists(input_path):
        print(f"Error: Input not found: {input_path}")
        return

    fix_icon_aggressive(input_path, output_path)
    print("Done!")

if __name__ == "__main__":
    main()
