# 🎨 Adding Custom ASCII Art

Want to add your own ASCII characters to the welcome screen? It's easy!

## How It Works

The `_get_cute_ascii()` function in `70-welcome.zsh` randomly selects one of 10 ASCII art characters each session.

## Adding a Character

### Step 1: Edit the function

Open `~/.zshrc.d/70-welcome.zsh` and find the `_get_cute_ascii()` function (around line 137).

### Step 2: Add a new case

Add your ASCII art as a new case. For example, adding a dragon:

```bash
11) # Dragon 🐉
  echo "\033[38;5;208m       ___====-_|_\033[0m"
  echo "\033[38;5;209m      /  ====-__/\033[0m"
  echo "\033[38;5;210m     /  ====-__/\033[0m"
  echo "\033[38;5;208m    < O   ====o\033[0m"
  echo "\033[38;5;209m     \ ====-__/\033[0m"
  echo "\033[38;5;210m      \\====-__/\033[0m"
  echo "\033[38;5;208m        🐉 Roooaaaar! Time to slay bugs! 🐉\033[0m"
  ;;
```

### Step 3: Update the random selection

Find this line:
```bash
local choice=$((RANDOM % 10 + 1))
```

Change it to:
```bash
local choice=$((RANDOM % 11 + 1))  # Now 11 characters instead of 10
```

### Step 4: Test it!

Restart your shell:
```bash
exec zsh
```

Keep opening new shells until you see your new character!

## Color Codes Explained

The ASCII art uses ANSI color codes. Here's the pattern:

```bash
echo "\033[38;5;XXXm  TEXT  \033[0m"
         ^^^^^^^^
         Color code (see below)
```

### Common Colors

| Code | Color | Usage |
|------|-------|-------|
| 226 | Bright Yellow | Pikachu |
| 218-220 | Pink/Magenta | Kirby, Ditto |
| 48-51 | Green/Cyan | Slime |
| 208-220 | Orange | Fox |
| 249-255 | Gray/White | Pusheen, Ghost |

Find more: [256 Color Cheat Sheet](https://i.stack.imgur.com/KTSQa.png)

## Tips for Great ASCII Art

1. **Keep it small** - Fits better in the welcome box
2. **Use multiple lines** - 6-8 lines is perfect
3. **Add personality** - Include a fun emoji and message
4. **Test colors** - Try different color codes until it looks right
5. **Keep messages short** - Max 50 characters

## Example: Minimal Character

```bash
9) # Smile 😊
  echo "\033[38;5;226m      ^_^\033[0m"
  echo "\033[38;5;227m     (^ ^)\033[0m"
  echo "\033[38;5;228m      \_/\033[0m"
  echo "\033[38;5;226m      😊 Happy coding! 😊\033[0m"
  ;;
```

## Example: Detailed Character

```bash
10) # Wizard 🧙
  echo "\033[38;5;135m       .___.\033[0m"
  echo "\033[38;5;141m      (◉ ◉ )\033[0m"
  echo "\033[38;5;147m       \ | /\033[0m"
  echo "\033[38;5;153m      --| |--\033[0m"
  echo "\033[38;5;147m        /|\\\033[0m"
  echo "\033[38;5;141m       / | \\\033[0m"
  echo "\033[38;5;135m      🧙 Abracadabra! Code magic time! 🧙\033[0m"
  ;;
```

## Submit Your Art!

Found an awesome ASCII character? Submit it as a PR! 🎉

Just include:
- The complete case statement
- What character number to use
- The updated random selection range

Happy creating! ✨
