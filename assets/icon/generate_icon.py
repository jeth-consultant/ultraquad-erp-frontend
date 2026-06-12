"""One-off script to generate the UltraQuad ERP app icon assets.

Produces:
  - icon.png            : 1024x1024 navy rounded-square with white bolt (legacy/iOS icon)
  - icon_foreground.png : 1024x1024 transparent background with white bolt (Android adaptive icon foreground)
"""

from PIL import Image, ImageDraw

SIZE = 1024
NAVY = (10, 31, 68, 255)  # 0xFF0A1F44

# Bolt silhouette, normalized to a 0-100 box, then scaled to SIZE.
BOLT_POINTS = [
    (58, 6),
    (28, 54),
    (46, 54),
    (40, 94),
    (74, 42),
    (54, 42),
]


def scale(points, box_size, target_size, inset):
    usable = target_size - 2 * inset
    return [
        (inset + (x / box_size) * usable, inset + (y / box_size) * usable)
        for x, y in points
    ]


def make_icon(path, with_background, inset):
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    if with_background:
        radius = SIZE * 0.22
        draw.rounded_rectangle([0, 0, SIZE, SIZE], radius=radius, fill=NAVY)

    bolt = scale(BOLT_POINTS, 100, SIZE, inset)
    draw.polygon(bolt, fill=(255, 255, 255, 255))

    img.save(path)


make_icon("icon.png", with_background=True, inset=SIZE * 0.22)
make_icon("icon_foreground.png", with_background=False, inset=SIZE * 0.30)

print("done")
