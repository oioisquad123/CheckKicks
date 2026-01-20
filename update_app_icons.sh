#!/bin/bash

SOURCE="/Users/bayuhidayat/.gemini/antigravity/brain/e13a9354-a6f1-407f-8a71-1e8fd0aeae6c/uploaded_image_1_1767571671274.jpg"
DEST_DIR="/Users/bayuhidayat/Document/Developer_Bayu/Auntentic_check_v2/Auntentic_AI/Auntentic_AI/Assets.xcassets/AppIcon.appiconset"

# Function to resize
resize() {
    size=$1
    name=$2
    echo "Generating $name ($size)..."
    sips -z $size $size -s format png "$SOURCE" --out "$DEST_DIR/$name"
}

resize 1024 "icon-1024.png"
resize 180 "icon-180.png"
resize 120 "icon-120.png"
resize 87 "icon-87.png"
resize 58 "icon-58.png"
resize 120 "icon-120-spotlight.png"
resize 80 "icon-80.png"
resize 167 "icon-167.png"
resize 152 "icon-152.png"
resize 76 "icon-76.png"
resize 80 "icon-80-ipad.png"
resize 40 "icon-40.png"
resize 58 "icon-58-ipad.png"
resize 29 "icon-29.png"

echo "App icons generated successfully as PNGs."
