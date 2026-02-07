# ═══════════════════════════════════════════════════════════════════════════════
# 🎨 70-WELCOME.ZSH - The Grand Terminal Awakening
# ═══════════════════════════════════════════════════════════════════════════════
# "Every session is a new performance - let the curtain rise! 🎭"
# - The Spellbinding Museum Director of Theatrical Introductions
#
# 🎯 This module contains:
#   - Time-based greetings (morning/afternoon/evening/late night)
#   - Random ASCII art collection (10 cute characters!)
#   - Developer jokes collection (14 gems)
#   - System stats display with CACHING ⚡ (10-min TTL)
#   - Git activity summary with CACHING (5-min TTL)
#   - Load time display (color-coded by speed)
#   - Quick aliases dashboard
#   - Hybrid ASCII/Image mode (if images in ~/.config/terminal-welcome/)
# ═══════════════════════════════════════════════════════════════════════════════

# 🎲 Developer Jokes Collection - One random joke per session! 🎭
# Because coding is 10% typing and 90% laughing at bugs
_get_dev_joke() {
  local jokes=(
    "Why do programmers prefer dark mode? Because light attracts bugs! 🐛"
    "There are only 10 types of people: those who understand binary and those who don't. 🔢"
    "A SQL query walks into a bar, approaches two tables and asks: 'Can I JOIN you?' 🍺"
    "Why do Java developers wear glasses? Because they can't C#! 👓"
    "!false — It's funny because it's true. ✨"
    "The best thing about a Boolean is even if you're wrong, you're only off by a bit. 🎯"
    "A programmer's wife tells him: 'Buy bread. If they have eggs, buy a dozen.' He returns with 12 loaves. 🍞"
    "To understand recursion, you must first understand recursion. 🔄"
    "Why was the developer unhappy at their job? They wanted arrays! 💰"
    "Debugging is like being the detective in a crime movie where you're also the murderer. 🔍"
    "Why do programmers hate nature? It has too many bugs. 🌲"
    "How many programmers does it take to change a light bulb? None, that's a hardware problem. 💡"
    "A QA engineer walks into a bar. Orders 1 beer. Orders 0 beers. Orders 99999999 beers. Orders -1 beers. Orders a lizard. 🦎"
    "In order to understand recursion, one must first understand recursion. 🌀"
    "Knock knock. Race condition. Who's there? 🚪"
  )
  echo "${jokes[$((RANDOM % ${#jokes[@]} + 1))]}"
}

# 🖥️ System Stats - FAST version with 10-minute TTL cache! ⚡
# This prevents running sysctl/vm_stat/df on EVERY shell startup
# Cache file: /tmp/zsh-system-stats-cache
_get_system_stats() {
  local cache_file="/tmp/zsh-system-stats-cache"
  local cache_age=600  # 💎 10 minutes TTL - system stats don't change that fast!

  # 🎭 Check cache first - fresh enough? Return it!
  if [[ -f "$cache_file" ]] && (( $(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || echo 0) < cache_age )); then
    cat "$cache_file"
    return
  fi

  # 🎬 Generate fresh stats
  # Skip CPU (too slow) - just show memory and disk
  local mem_total=$(( $(sysctl -n hw.memsize 2>/dev/null) / 1073741824 ))
  local mem_pages=$(vm_stat 2>/dev/null | awk '/Pages active|Pages wired/ {gsub(/\./,""); sum+=$NF} END {print sum}')
  local mem_used=$(( mem_pages * 4096 / 1073741824 ))
  local disk_used=$(df -h / 2>/dev/null | awk 'NR==2 {gsub(/%/,""); print $5}')
  local uptime_info=$(uptime 2>/dev/null | sed 's/.*up //' | sed 's/,.*//' | tr -d ' ')

  local result=$(printf "MEM: %d/%dGB │ DISK: %s%% │ ⬆️  %s" \
    "${mem_used:-0}" "${mem_total:-32}" "${disk_used:-?}" "${uptime_info:-?}")

  # 💎 Cache for next time
  echo "$result" > "$cache_file"
  echo "$result"
}

# 📦 Recent Git Activity - FAST cached version (5-min TTL)
# Scans ~/Developer for recent git activity across repos
# 🛡️ Includes simple file locking to prevent race conditions between shells
_get_git_activity() {
  local cache_file="/tmp/zsh-git-activity-cache"
  local lock_file="/tmp/zsh-git-activity-cache.lock"
  local cache_age=300  # 💎 5 minutes TTL - git activity isn't that frantic

  # Use cache if fresh enough
  if [[ -f "$cache_file" ]] && (( $(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || echo 0) < cache_age )); then
    cat "$cache_file"
    return
  fi

  # 🔒 Simple lock mechanism to prevent race conditions
  # If lock exists and is less than 30 seconds old, another shell is generating
  if [[ -f "$lock_file" ]] && (( $(date +%s) - $(stat -f %m "$lock_file" 2>/dev/null || echo 0) < 30 )); then
    # Wait briefly for other process, then use cache (even if stale)
    sleep 0.2
    [[ -f "$cache_file" ]] && cat "$cache_file"
    return
  fi

  # 🎭 Acquire lock (touch creates/updates timestamp)
  touch "$lock_file" 2>/dev/null

  # Generate fresh cache in background-friendly way
  local developer_dir="$HOME/Developer"
  [[ ! -d "$developer_dir" ]] && { rm -f "$lock_file" 2>/dev/null; return; }

  {
    local count=0
    for gitdir in "$developer_dir"/*/.git(N) "$developer_dir"/*/*/.git(N); do
      [[ $count -ge 3 ]] && break
      [[ ! -d "$gitdir" ]] && continue
      local repo_dir="${gitdir:h}"
      local repo_name="${repo_dir:t}"
      local commit_info=$(cd "$repo_dir" && git log -1 --format="%cr|%s" 2>/dev/null)
      [[ -z "$commit_info" ]] && continue
      local time_ago="${commit_info%%|*}"
      time_ago="${time_ago// ago/}"
      time_ago="${time_ago// /}"
      local message="${commit_info#*|}"
      message="${message:0:35}"
      printf "  \033[38;5;114m•\033[0m \033[38;5;117m%-22s\033[0m → \033[38;5;245m%s\033[0m \033[38;5;244m\"%s\"\033[0m\n" "$repo_name" "$time_ago" "$message"
      ((count++))
    done
  } | tee "$cache_file"

  # 🔓 Release lock
  rm -f "$lock_file" 2>/dev/null
}

# 🌟 Time-based greeting - because context matters!
_get_greeting() {
  local hour=$(date +%H)
  if (( hour >= 5 && hour < 12 )); then
    echo "☀️  Good morning, creator!"
  elif (( hour >= 12 && hour < 17 )); then
    echo "🌤️  Good afternoon, wizard!"
  elif (( hour >= 17 && hour < 21 )); then
    echo "🌆 Good evening, architect!"
  else
    echo "🌙 Working late? You magnificent owl!"
  fi
}

# 🎨 Cute ASCII Art Collection - Rotates randomly each session!
# 10 adorable friends to brighten your terminal day 🎭
_get_cute_ascii() {
  local choice=$((RANDOM % 10 + 1))
  case $choice in
    1) # Pikachu-style electric mouse ⚡
      echo "\033[38;5;226m      ⢀⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⣠⣤⣶⣶\033[0m"
      echo "\033[38;5;226m      ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⢰⣿⣿⣿⣿\033[0m"
      echo "\033[38;5;227m      ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⣀⣀⣾⣿⣿⣿⣿\033[0m"
      echo "\033[38;5;228m      ⣿⣿⣿⣿⣿⡏⠉⠛⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣿\033[0m"
      echo "\033[38;5;229m      ⣿⣿⣿⣿⣿⣿⠀⠀⠀⠈⠛⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⠉⠁⠀⣿\033[0m"
      echo "\033[38;5;230m      ⣿⣿⣿⣿⣿⣿⣧⡀⠀⠀⠀⠀⠙⠿⠿⠿⠻⠿⠿⠟⠿⠛⠉⠀⠀⠀⠀⠀⣸⣿\033[0m"
      echo "\033[38;5;228m        ⚡ Pika Pika! Ready to code? ⚡\033[0m"
      ;;
    2) # Cute cat 🐱
      echo "\033[38;5;215m        /\\_____/\\\033[0m"
      echo "\033[38;5;215m       /  o   o  \\\033[0m"
      echo "\033[38;5;216m      ( ==  ^  == )\033[0m"
      echo "\033[38;5;217m       )         (\033[0m"
      echo "\033[38;5;218m      (           )\033[0m"
      echo "\033[38;5;219m     ( (  )   (  ) )\033[0m"
      echo "\033[38;5;220m    (__(__)___(__)__)\033[0m"
      echo "\033[38;5;218m        🐱 Meow! Time to purrogram! 🐱\033[0m"
      ;;
    3) # Kirby 🌟
      echo "\033[38;5;218m        ⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣄⠀\033[0m"
      echo "\033[38;5;219m      ⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦\033[0m"
      echo "\033[38;5;218m      ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿\033[0m"
      echo "\033[38;5;217m      ⣿⣿⣿⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠈⠻⣿⣿⣿⣿⣿\033[0m"
      echo "\033[38;5;218m      ⣿⣿⣿⠟⠁⠀⢀⣤⣤⠀⠀⣤⣤⡀⠀⠀⠈⠻⣿⣿⣿\033[0m"
      echo "\033[38;5;219m        ⠙⠁⠀⠀⠀⣿⣿⣿⠀⠀⣿⣿⣿⠀⠀⠀⠈⠋⠀\033[0m"
      echo "\033[38;5;218m        🌟 Poyo! Let's absorb some code! 🌟\033[0m"
      ;;
    4) # Pusheen 🍪
      echo "\033[38;5;249m       ╱|、\033[0m"
      echo "\033[38;5;250m      (˚ˎ 。7\033[0m"
      echo "\033[38;5;251m       |、˜〵\033[0m"
      echo "\033[38;5;252m       じしˍ,)ノ\033[0m"
      echo "\033[38;5;253m        🍪 Pusheen wants cookies & code! 🍪\033[0m"
      ;;
    5) # Totoro 🌳
      echo "\033[38;5;248m         ╭━━━━━╮\033[0m"
      echo "\033[38;5;249m        ╱ ●   ● ╲\033[0m"
      echo "\033[38;5;250m       ╱    ▽    ╲\033[0m"
      echo "\033[38;5;251m      ╱   ╱   ╲   ╲\033[0m"
      echo "\033[38;5;252m     ╱___╱_____╲___╲\033[0m"
      echo "\033[38;5;250m        🌳 Totoro says: Plant good code! 🌳\033[0m"
      ;;
    6) # Ghost 👻
      echo "\033[38;5;231m        .----.\033[0m"
      echo "\033[38;5;255m       /  😳  \\\033[0m"
      echo "\033[38;5;254m      |   👻   |\033[0m"
      echo "\033[38;5;253m      |        |\033[0m"
      echo "\033[38;5;252m       \\  \\/  /\033[0m"
      echo "\033[38;5;251m        \\_/\\_/\033[0m"
      echo "\033[38;5;253m        👻 Boo! Don't be scared of bugs! 👻\033[0m"
      ;;
    7) # Slime 🟢
      echo "\033[38;5;48m        ╭──────╮\033[0m"
      echo "\033[38;5;49m       ╱ ◉    ◉ ╲\033[0m"
      echo "\033[38;5;50m      │    ◡    │\033[0m"
      echo "\033[38;5;51m      │          │\033[0m"
      echo "\033[38;5;50m       ╲________╱\033[0m"
      echo "\033[38;5;49m        🟢 Slime says: Keep it simple! 🟢\033[0m"
      ;;
    8) # Ditto 🩷
      echo "\033[38;5;219m        ╭━━━━━━╮\033[0m"
      echo "\033[38;5;218m       ╱        ╲\033[0m"
      echo "\033[38;5;217m      │  ·    ·  │\033[0m"
      echo "\033[38;5;218m      │    ‿‿    │\033[0m"
      echo "\033[38;5;219m       ╲________╱\033[0m"
      echo "\033[38;5;218m        🩷 Ditto can transform your code! 🩷\033[0m"
      ;;
    9) # Cute Robot 🤖
      echo "\033[38;5;117m        ┌─────┐\033[0m"
      echo "\033[38;5;81m        │ ◠ ◠ │\033[0m"
      echo "\033[38;5;75m        │  ▽  │\033[0m"
      echo "\033[38;5;69m       ┌┴─────┴┐\033[0m"
      echo "\033[38;5;63m       │ ║   ║ │\033[0m"
      echo "\033[38;5;57m       └───────┘\033[0m"
      echo "\033[38;5;117m        🤖 Beep boop! Ready to assist! 🤖\033[0m"
      ;;
    10) # Fox 🦊
      echo "\033[38;5;208m        /\\   /\\\033[0m"
      echo "\033[38;5;209m       //\\\\_//\\\\\033[0m"
      echo "\033[38;5;215m       \\_     _/\033[0m"
      echo "\033[38;5;216m        / * * \\\033[0m"
      echo "\033[38;5;217m       /   w   \\\033[0m"
      echo "\033[38;5;223m      /    |    \\\033[0m"
      echo "\033[38;5;208m        🦊 What does the fox say? Code! 🦊\033[0m"
      ;;
  esac
}

# 🖼️ VIU Image Welcome - Display a random image from welcome directory
# Add images to: ~/.config/terminal-welcome/ for 30% chance to show one!
_show_viu_welcome() {
  local welcome_dir="$HOME/.config/terminal-welcome"
  [[ ! -d "$welcome_dir" ]] && return 1

  local -a images
  images=("${welcome_dir}"/*.{png,jpg,jpeg,gif,webp}(N))

  [[ ${#images[@]} -eq 0 ]] && return 1

  # Pick a random image
  local random_img="${images[$((RANDOM % ${#images[@]} + 1))]}"

  # Display with viu (width 50 for nice compact display)
  viu -w 50 "$random_img" 2>/dev/null
  return 0
}

# ⏱️ Calculate and display load time
# Color-coded: green < 1s, yellow 1-2s, red > 2s
_show_load_time() {
  if [[ -n "$ZSHRC_START_TIME" ]]; then
    local end_time=$(($(date +%s%N)/1000000))
    local load_ms=$((end_time - ZSHRC_START_TIME))
    local load_sec=$(printf "%.2f" $(echo "scale=2; $load_ms / 1000" | bc))

    # Color based on speed: green < 1s, yellow 1-2s, red > 2s
    local color
    if (( load_ms < 1000 )); then
      color="38;5;114"  # Green - fast! ⚡
    elif (( load_ms < 2000 )); then
      color="38;5;228"  # Yellow - okay
    else
      color="38;5;203"  # Red - slow 🐌
    fi

    echo "\033[${color}m⚡ Shell loaded in ${load_sec}s\033[0m"
  fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🎭 THE GRAND WELCOME PERFORMANCE
# ═══════════════════════════════════════════════════════════════════════════════
# Only show once per session (respects ZSHRC_WELCOME_SHOWN)
if [[ -z "$ZSHRC_WELCOME_SHOWN" ]]; then
  # Track that we've shown welcome (don't show on reload)
  export ZSHRC_WELCOME_SHOWN=1

  # 🎬 Gather info for display
  local greeting=$(_get_greeting)
  local current_date=$(date "+%a %b %d, %Y • %I:%M %p")
  local joke=$(_get_dev_joke)
  local system_stats=$(_get_system_stats)

  echo ""

  # 🎨 Check if we should show image or ASCII
  local welcome_dir="$HOME/.config/terminal-welcome"
  local has_images=false
  if [[ -d "$welcome_dir" ]]; then
    local -a welcome_images
    welcome_images=("${welcome_dir}"/*.{png,jpg,jpeg,gif,webp}(N))
    [[ ${#welcome_images[@]} -gt 0 ]] && has_images=true
  fi

  # If we have images and roll 80%, show image mode
  if $has_images && (( RANDOM % 100 < 80 )); then
    # 🖼️ IMAGE MODE - viu image with compact info below
    _show_viu_welcome
    echo ""
    echo "  \033[38;5;228m${greeting}\033[0m  \033[38;5;244m│\033[0m  \033[38;5;250m${current_date}\033[0m"
    echo "  \033[38;5;245m${system_stats}\033[0m"
  else
    # 🎨 ASCII MODE - Full decorative box with ASCII art
    echo "\033[38;5;147m  ╔══════════════════════════════════════════════════════════════════════╗\033[0m"
    echo "\033[38;5;147m  ║\033[0m                                                                      \033[38;5;147m║\033[0m"
    _get_cute_ascii | while read line; do echo "\033[38;5;147m  ║\033[0m  $line                    \033[38;5;147m║\033[0m"; done
    echo "\033[38;5;147m  ║\033[0m                                                                      \033[38;5;147m║\033[0m"
    echo "\033[38;5;147m  ║\033[0m   \033[38;5;228m${greeting}\033[0m  \033[38;5;244m│\033[0m  \033[38;5;250m${current_date}\033[0m       \033[38;5;147m║\033[0m"
    echo "\033[38;5;147m  ║\033[0m   \033[38;5;244m──────────────────────────────────────────────────────────────────\033[0m   \033[38;5;147m║\033[0m"
    echo "\033[38;5;147m  ║\033[0m   \033[38;5;245m${system_stats}\033[0m              \033[38;5;147m║\033[0m"
    echo "\033[38;5;147m  ║\033[0m                                                                      \033[38;5;147m║\033[0m"
    echo "\033[38;5;147m  ╚══════════════════════════════════════════════════════════════════════╝\033[0m"
  fi

  echo ""
  echo "  \033[38;5;228m💭\033[0m \033[38;5;252m\"${joke}\"\033[0m"
  echo ""

  # Git Activity (quick scan, cached)
  echo "  \033[38;5;114m📦 Recent Git Activity:\033[0m"
  _get_git_activity
  echo ""

  # ⚡ Performance Tips
  echo "\033[38;5;202m  ━\033[38;5;208m━\033[38;5;214m━\033[38;5;220m━\033[38;5;226m━\033[38;5;190m━\033[38;5;154m━\033[38;5;118m━\033[38;5;82m━\033[38;5;46m━\033[38;5;47m━\033[38;5;48m━\033[38;5;49m━\033[38;5;50m━\033[38;5;51m━\033[38;5;45m━\033[38;5;39m━\033[38;5;33m━\033[38;5;27m━\033[38;5;21m━\033[38;5;57m━\033[38;5;93m━\033[38;5;129m━\033[38;5;165m━\033[38;5;201m━\033[38;5;200m━\033[38;5;199m━\033[38;5;198m━\033[38;5;197m━\033[38;5;196m━\033[38;5;202m━\033[38;5;208m━\033[38;5;214m━\033[38;5;220m━\033[38;5;226m━\033[38;5;190m━\033[38;5;154m━\033[38;5;118m━\033[38;5;82m━\033[38;5;46m━\033[38;5;47m━\033[38;5;48m━\033[38;5;49m━\033[38;5;50m━\033[38;5;51m━\033[38;5;45m━\033[38;5;39m━\033[38;5;33m━\033[38;5;27m━\033[38;5;21m━\033[38;5;57m━\033[38;5;93m━\033[38;5;129m━\033[38;5;165m━\033[38;5;201m━\033[38;5;200m━\033[38;5;199m━\033[38;5;198m━\033[38;5;197m━\033[38;5;196m━\033[38;5;202m━\033[38;5;208m━\033[38;5;214m━\033[38;5;220m━\033[38;5;226m━\033[38;5;190m━\033[38;5;154m━\033[38;5;118m━\033[38;5;82m━\033[38;5;46m━\033[38;5;47m━\033[38;5;48m━\033[0m"
  echo "  \033[38;5;226m⚡ CUSTOMIZE ME!\033[0m \033[38;5;245m✨\033[0m"
  echo "\033[38;5;240m  ─────────────────────────────────────────────────────────────────────────────\033[0m"
  echo "  \033[38;5;220m🎨 Add your own jokes!\033[0m \033[38;5;245mEdit _get_dev_joke() in this file\033[0m"
  echo "  \033[38;5;220m📦 Add your own ASCII art!\033[0m \033[38;5;245mSee examples/ directory\033[0m"
  echo "  \033[38;5;220m🖼️  Add custom images!\033[0m \033[38;5;245mPut .png/.jpg in ~/.config/terminal-welcome/\033[0m"
  echo ""

  # ⏱️ Show load time at the very end
  echo "  $(_show_load_time)"
  echo ""
fi

# ═══════════════════════════════════════════════════════════════════════════════
# 🎭 Curtain closes on another magnificent session!
# "The show must go on..." - Some dramatic theatre person probably
# ═══════════════════════════════════════════════════════════════════════════════
