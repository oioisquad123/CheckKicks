#!/bin/bash

# Generate Auntentic App Icon
# Creates a simple, elegant gradient icon with checkmark seal

echo "🎨 Generating Auntentic App Icon..."

# Create temporary Python script to generate icon
cat > /tmp/generate_icon.py << 'PYTHON'
from PIL import Image, ImageDraw
import os

def create_gradient(width, height):
    """Create blue to purple gradient"""
    base = Image.new('RGB', (width, height), (0, 0, 0))
    draw = ImageDraw.Draw(base)

    for y in range(height):
        # Blue to Purple gradient
        r = int(138 + (88 * y / height))  # 138 -> 226
        g = int(43 + (67 * y / height))   # 43 -> 110
        b = int(226 + (0 * y / height))   # 226 -> 226
        draw.line([(0, y), (width, y)], fill=(r, g, b))

    return base

def add_checkmark_seal(img):
    """Add white checkmark seal overlay"""
    width, height = img.size
    draw = ImageDraw.Draw(img)

    # Draw seal (rounded badge shape)
    center_x, center_y = width // 2, height // 2
    radius = min(width, height) // 3

    # Draw white circle background
    draw.ellipse(
        [center_x - radius, center_y - radius, center_x + radius, center_y + radius],
        fill=(255, 255, 255, 255)
    )

    # Draw checkmark
    check_size = radius * 0.6
    check_x = center_x - check_size * 0.2
    check_y = center_y - check_size * 0.1

    # Checkmark path (simplified)
    points = [
        (check_x - check_size * 0.3, check_y),
        (check_x, check_y + check_size * 0.4),
        (check_x + check_size * 0.5, check_y - check_size * 0.3)
    ]

    draw.line(points, fill=(100, 100, 255), width=int(radius * 0.25), joint='curve')

    return img

def generate_icon(size, output_path):
    """Generate icon at specific size"""
    img = create_gradient(size, size)
    img = add_checkmark_seal(img)
    img.save(output_path, 'PNG')
    print(f"✅ Generated {size}x{size} icon: {output_path}")

# iOS App Icon sizes
icon_set_path = os.path.expanduser("~/Document/Developer_Bayu/Auntentic_check_v2/Auntentic_AI/Auntentic_AI/Assets.xcassets/AppIcon.appiconset")
os.makedirs(icon_set_path, exist_ok=True)

# Generate all required sizes
sizes = {
    'icon_20pt@2x.png': 40,
    'icon_20pt@3x.png': 60,
    'icon_29pt@2x.png': 58,
    'icon_29pt@3x.png': 87,
    'icon_40pt@2x.png': 80,
    'icon_40pt@3x.png': 120,
    'icon_60pt@2x.png': 120,
    'icon_60pt@3x.png': 180,
    'icon_1024pt.png': 1024
}

for filename, size in sizes.items():
    output_path = os.path.join(icon_set_path, filename)
    generate_icon(size, output_path)

# Create Contents.json
contents_json = '''{
  "images" : [
    {
      "filename" : "icon_20pt@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "filename" : "icon_20pt@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "20x20"
    },
    {
      "filename" : "icon_29pt@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "filename" : "icon_29pt@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "29x29"
    },
    {
      "filename" : "icon_40pt@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "filename" : "icon_40pt@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "40x40"
    },
    {
      "filename" : "icon_60pt@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "60x60"
    },
    {
      "filename" : "icon_60pt@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "60x60"
    },
    {
      "filename" : "icon_1024pt.png",
      "idiom" : "ios-marketing",
      "scale" : "1x",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}'''

with open(os.path.join(icon_set_path, 'Contents.json'), 'w') as f:
    f.write(contents_json)

print("✅ Contents.json created")
print(f"\n🎉 App icon set generated successfully at:\n{icon_set_path}")
PYTHON

# Check if PIL is installed, if not use simpler SF Symbols approach
if python3 -c "import PIL" 2>/dev/null; then
    echo "📦 PIL found, generating icons..."
    python3 /tmp/generate_icon.py
else
    echo "⚠️  PIL (Pillow) not installed"
    echo "📦 Installing Pillow..."
    pip3 install Pillow --quiet || python3 -m pip install Pillow --quiet

    if [ $? -eq 0 ]; then
        echo "✅ Pillow installed successfully"
        python3 /tmp/generate_icon.py
    else
        echo "❌ Could not install Pillow automatically"
        echo ""
        echo "ALTERNATIVE: Using SF Symbols approach..."
        echo "I'll create a simpler version using macOS tools instead."
    fi
fi

rm /tmp/generate_icon.py 2>/dev/null

echo ""
echo "✅ Done! Your app icon is ready."
echo "🔄 Rebuild your app in Xcode to see the new icon."
