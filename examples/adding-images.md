# 🖼️ Adding Custom Images

The welcome screen supports displaying random images! Here's how to set it up.

## Prerequisites

Install `viu` (terminal image viewer):

```bash
# macOS
brew install viu

# Linux
cargo install viu

# Or from source
https://github.com/atanunq/viu
```

## Setup Images

### Step 1: Create the directory

```bash
mkdir -p ~/.config/terminal-welcome/
```

### Step 2: Add images

Copy your favorite images (PNG, JPG, GIF, WebP):

```bash
cp ~/Pictures/awesome-wallpaper.png ~/.config/terminal-welcome/
cp ~/Pictures/cool-art.jpg ~/.config/terminal-welcome/
```

### Step 3: Restart shell

```bash
exec zsh
```

Now every time you open a shell, there's an **80% chance** an image displays instead of ASCII art!

## Behavior

- **With images:** 80% chance to show a random image
- **Without images:** 20% chance + fallback to ASCII art
- Images are randomly selected from `~/.config/terminal-welcome/`
- Always falls back to ASCII art if viu isn't installed or images don't load

## Tips for Best Results

### Image Size
- **Optimal:** 400-800px wide
- Small images scale up, large images scale down
- Aspect ratio is preserved

### File Format
- ✅ PNG (best quality)
- ✅ JPG (good for photos)
- ✅ WebP (modern, small file size)
- ✅ GIF (animated!)

### Content Ideas
- Inspiring quotes
- Beautiful artwork
- Memes
- Project screenshots
- Team photos
- Motivational posters

## Disable Image Mode

Prefer ASCII art? Set the probability in `70-welcome.zsh`:

```bash
# Find this line (around line 298):
if $has_images && (( RANDOM % 100 < 80 )); then
    # Change 80 to 0 to disable images
    # Change 80 to 50 for 50/50 split
    # Change 80 to 100 to always show images
```

## Common Issues

### Images don't display

1. **Check viu is installed:**
   ```bash
   which viu
   viu --version
   ```

2. **Check images exist:**
   ```bash
   ls ~/.config/terminal-welcome/
   ```

3. **Test viu manually:**
   ```bash
   viu ~/.config/terminal-welcome/image.png
   ```

### Images are too big/small

Adjust the width in `70-welcome.zsh` (around line 246):

```bash
# Find this line:
viu -w 50 "$random_img" 2>/dev/null

# Change 50 to your preferred width (in characters)
# Try: 40 (narrow), 60 (wide), 80 (very wide)
```

### Performance issues

Image display may slow startup slightly. If it's too slow:
- Use fewer/smaller images
- Use JPEG instead of PNG (more compressed)
- Increase image cache timeout in the code

## Examples

### Inspiring Quote Image

Create a simple text image:
```bash
convert -size 400x200 xc:white \
  -font Helvetica -pointsize 24 \
  -draw "text 50,100 'Keep Coding!'" \
  quote.png
```

### Simple Color Block

```bash
convert -size 400x300 xc:'#1e90ff' simple.png
```

### From Screenshot

```bash
# macOS: Take screenshot and save
screencapture ~/Pictures/screenshot.png

# Move to terminal-welcome
mv ~/Pictures/screenshot.png ~/.config/terminal-welcome/
```

## See Also

- [viu GitHub](https://github.com/atanunq/viu)
- [ImageMagick](https://imagemagick.org/)
- [Creating ASCII art from images](https://img2txt.com/)

---

Happy decorating! 🎨✨
