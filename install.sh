#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# 🎭 Terminal Welcome Theme - Installation Script
# ═══════════════════════════════════════════════════════════════════════════════
# "Where setup becomes a performance art..." 🎬

set -e  # Exit on error

# 🎨 Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🎭 Terminal Welcome Theme Installer${NC}"
echo ""

# 📁 Create directories
echo -e "${BLUE}📁 Setting up directories...${NC}"
mkdir -p ~/.zshrc.d
mkdir -p ~/.config/terminal-welcome

# 📋 Copy modules
echo -e "${BLUE}📋 Installing modules...${NC}"
cp .zshrc.d/00-init.zsh ~/.zshrc.d/
cp .zshrc.d/70-welcome.zsh ~/.zshrc.d/
echo -e "${GREEN}✅ Modules installed!${NC}"

# 🔍 Check if .zshrc exists
if [[ ! -f ~/.zshrc ]]; then
  echo -e "${YELLOW}⚠️  ~/.zshrc not found. Creating from example...${NC}"
  cp .zshrc.example ~/.zshrc
  echo -e "${GREEN}✅ Created ~/.zshrc${NC}"
else
  # 🔍 Check if module loading is already present
  if grep -q "ZSH_MOD_DIR" ~/.zshrc; then
    echo -e "${GREEN}✅ Module loading already configured in ~/.zshrc${NC}"
  else
    echo -e "${YELLOW}⚠️  Adding module loading to ~/.zshrc...${NC}"
    cat .zshrc.example >> ~/.zshrc
    echo -e "${GREEN}✅ Added module loading system${NC}"
  fi
fi

# 🖼️ Optional: viu for image support
if ! command -v viu &> /dev/null; then
  echo ""
  echo -e "${YELLOW}📸 Optional: Install viu for custom image support?${NC}"
  echo "   viu lets you display custom images in the welcome screen"
  read -p "Install viu? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v brew &> /dev/null; then
      echo -e "${BLUE}Installing viu via Homebrew...${NC}"
      brew install viu
      echo -e "${GREEN}✅ viu installed!${NC}"
    else
      echo -e "${RED}❌ Homebrew not found. Install viu manually:${NC}"
      echo "   https://github.com/atanunq/viu"
    fi
  fi
else
  echo -e "${GREEN}✅ viu already installed${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Installation complete!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Restart your shell: ${YELLOW}exec zsh${NC}"
echo "  2. Enjoy your new welcome screen! 🎭"
echo ""
echo -e "${BLUE}Customization:${NC}"
echo "  • Add jokes: Edit ~/.zshrc.d/70-welcome.zsh"
echo "  • Add images: Put .png/.jpg in ~/.config/terminal-welcome/"
echo "  • Add ASCII art: See examples/ directory"
echo ""
echo -e "${BLUE}More info: Read README.md${NC}"
