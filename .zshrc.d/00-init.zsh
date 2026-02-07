# ═══════════════════════════════════════════════════════════════════════════════
# 🎭 00-INIT.ZSH - The Foundation Stones
# ═══════════════════════════════════════════════════════════════════════════════
# "Before the castle can rise, the cornerstone must be laid..."
# - The Spellbinding Museum Director of Shell Foundations
# ═══════════════════════════════════════════════════════════════════════════════

# ⏱️ TIMING: Capture start time for load profiling
# Tracks how long the shell takes to load - helps us spot slow modules! 🐌
# Measure twice, cut once, as the mystical carpenters say. 📏
typeset -g ZSHRC_START_TIME=$(($(date +%s%N)/1000000))

# 🍎 Apple Silicon / Intel detection - The Smart Path Configuration
# On Apple Silicon (M1/M2/M3), Homebrew lives in /opt/homebrew
# On Intel, it lives in /usr/local
# This ensures we get the native binaries for maximum performance! ⚡
if [[ $(uname -m) == "arm64" ]]; then
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
else
  export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
fi

# 🟢 Node.js - The JavaScript Runtime of Choice
# You can customize this version based on your preference
# Check available versions with: brew search node
# export PATH="/opt/homebrew/opt/node@22/bin:$PATH"  # Uncomment if you use Node.js

# 🎯 Note: Additional environment setup can be added here
# Keep this init lean and mean - just the essentials! 💪
# ═══════════════════════════════════════════════════════════════════════════════
