#!/usr/bin/env python3
"""
Script to create app icons from the Kin logo image
Requires: pip install Pillow
"""
from PIL import Image
import os

# Icon sizes needed for Android
icon_sizes = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
}

# Load the original image from the attachment
# You need to save the Kin logo image to this path first
image_path = 'kin_logo.png'  # Save your logo image as this filename

if not os.path.exists(image_path):
    print(f"Error: {image_path} not found!")
    print("Please save your Kin Jewellery logo as 'kin_logo.png' in the project root")
    exit(1)

# Open the image
img = Image.open(image_path)

# Create icons for each density
base_path = r'android\app\src\main\res'

for folder, size in icon_sizes.items():
    # Resize image to the required size
    resized_img = img.resize((size, size), Image.Resampling.LANCZOS)
    
    # Create directory if it doesn't exist
    icon_dir = os.path.join(base_path, folder)
    os.makedirs(icon_dir, exist_ok=True)
    
    # Save the icon
    icon_path = os.path.join(icon_dir, 'ic_launcher.png')
    resized_img.save(icon_path, 'PNG')
    print(f"✓ Created {icon_path} ({size}x{size})")

print("\n✅ All app icons created successfully!")
