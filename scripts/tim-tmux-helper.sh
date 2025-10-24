#!/usr/bin/env bash
# ╭─────────────────────────────────────────────────────────────╮
# │                   TIM TMUX HELPER SCRIPT                    │
# ╰─────────────────────────────────────────────────────────────╯
#
# This script provides helper functions for tmux integration with tim
# Save as ~/.local/bin/tim-tmux-helper.sh and make executable

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Configuration
TIM_CMD="tim"
REFRESH_INTERVAL=1

# Function to check if tim is available
check_tim() {
  if ! command -v "$TIM_CMD" &>/dev/null; then
    echo "⚠️  Tim command not found. Please ensure 'tim' is in your PATH."
    return 1
  fi
  return 0
}

# Function to refresh tmux status variables
refresh_tmux_status() {
  if check_tim && tmux list-sessions &>/dev/null; then
    # Simple approach - just ensure tmux knows tim is available
    tmux set-environment -g TIM_AVAILABLE "yes" 2>/dev/null || true
  else
    tmux set-environment -g TIM_AVAILABLE "no" 2>/dev/null || true
  fi
}

# Function to setup tmux integration
setup_tmux_integration() {
  echo -e "${BLUE}🔧 Setting up Tim-Tmux integration...${NC}"

  # Check dependencies
  local deps=("tmux" "fzf" "$TIM_CMD")
  local missing_deps=()

  for dep in "${deps[@]}"; do
    if ! command -v "$dep" &>/dev/null; then
      missing_deps+=("$dep")
    fi
  done

  if [ ${#missing_deps[@]} -ne 0 ]; then
    echo -e "${RED}❌ Missing dependencies: ${missing_deps[*]}${NC}"
    echo -e "${YELLOW}Please install the missing dependencies and try again.${NC}"
    return 1
  fi

  # Initialize tmux environment variables
  refresh_tmux_status

  # Create periodic refresh script
  cat >~/.local/bin/tim-tmux-refresh.sh <<'EOF'
#!/usr/bin/env bash
# Auto-refresh tim availability in tmux
while true; do
    if tmux list-sessions &> /dev/null; then
        if command -v tim &> /dev/null; then
            tmux set-environment -g TIM_AVAILABLE "yes" 2>/dev/null
        else
            tmux set-environment -g TIM_AVAILABLE "no" 2>/dev/null
        fi
    fi
    sleep 5  # Check every 5 seconds
done
EOF

  chmod +x ~/.local/bin/tim-tmux-refresh.sh

  echo -e "${GREEN}✅ Tim-Tmux integration setup complete!${NC}"
  echo -e "${CYAN}💡 Key bindings:${NC}"
  echo -e "   ${GRAY}prefix + T${NC}     - Tim menu"
  echo -e "   ${GRAY}prefix + C-s${NC}   - Quick start"
  echo -e "   ${GRAY}prefix + C-o${NC}   - Quick stop"
  echo -e "   ${GRAY}prefix + C-t${NC}   - Status popup"
  echo -e "   ${GRAY}prefix + C-u${NC}   - Summary popup"
  echo -e "   ${GRAY}prefix + C-g${NC}   - Graph popup"
  echo -e "   ${GRAY}prefix + C-T${NC}   - Tag selection"
  echo ""
  echo -e "${CYAN}💡 Commands (prefix + :):${NC}"
  echo -e "   ${GRAY}:tim-start${NC}     - Start tracking"
  echo -e "   ${GRAY}:tim-stop${NC}      - Stop tracking"
  echo -e "   ${GRAY}:tim-status${NC}    - Show status"
  echo -e "   ${GRAY}:tim-summary${NC}   - Show summary"
  echo -e "   ${GRAY}:tim-graph${NC}     - Show graph"
  echo -e "   ${GRAY}:tim-add-tag${NC}   - Add new tag"
}

# Function to start the background refresh daemon
start_refresh_daemon() {
  if pgrep -f "tim-tmux-refresh.sh" >/dev/null; then
    echo -e "${YELLOW}⚡ Tim refresh daemon already running${NC}"
    return 0
  fi

  if [ -f ~/.local/bin/tim-tmux-refresh.sh ]; then
    nohup ~/.local/bin/tim-tmux-refresh.sh >/dev/null 2>&1 &
    echo -e "${GREEN}⚡ Started Tim refresh daemon (PID: $!)${NC}"
  else
    echo -e "${RED}❌ Refresh script not found. Run setup first.${NC}"
    return 1
  fi
}

# Function to stop the background refresh daemon
stop_refresh_daemon() {
  if pgrep -f "tim-tmux-refresh.sh" >/dev/null; then
    pkill -f "tim-tmux-refresh.sh"
    echo -e "${GREEN}🛑 Stopped Tim refresh daemon${NC}"
  else
    echo -e "${YELLOW}⚠️  No Tim refresh daemon running${NC}"
  fi
}

# Function to show current integration status
show_status() {
  echo -e "${BLUE}📊 Tim-Tmux Integration Status${NC}"
  echo ""

  # Check if tim is available
  if check_tim; then
    echo -e "   ${GREEN}✅ Tim command: Available${NC}"

    # Show current tim status
    local current_status
    current_status=$($TIM_CMD tmux-status 2>/dev/null)
    if [ $? -eq 0 ]; then
      echo -e "   ${GREEN}✅ Tim status: $current_status${NC}"
    else
      echo -e "   ${RED}❌ Tim status: Error getting status${NC}"
    fi
  else
    echo -e "   ${RED}❌ Tim command: Not found${NC}"
  fi

  # Check if tmux is running
  if tmux list-sessions &>/dev/null; then
    echo -e "   ${GREEN}✅ Tmux: Running${NC}"

    # Check tmux environment variables
    local tim_available
    tim_available=$(tmux show-environment TIM_AVAILABLE 2>/dev/null | cut -d= -f2 2>/dev/null)

    if [ "$tim_available" = "yes" ]; then
      echo -e "   ${GREEN}✅ Tmux integration: Active${NC}"
    else
      echo -e "   ${YELLOW}⚠️  Tmux integration: Tim not available${NC}"
    fi
  else
    echo -e "   ${YELLOW}⚠️  Tmux: Not running${NC}"
  fi

  # Check if refresh daemon is running
  if pgrep -f "tim-tmux-refresh.sh" >/dev/null; then
    echo -e "   ${GREEN}✅ Refresh daemon: Running${NC}"
  else
    echo -e "   ${YELLOW}⚠️  Refresh daemon: Not running${NC}"
  fi

  # Check dependencies
  echo ""
  echo -e "${BLUE}📦 Dependencies:${NC}"
  local deps=("tmux" "fzf" "tim")
  for dep in "${deps[@]}"; do
    if command -v "$dep" &>/dev/null; then
      local version
      case $dep in
      "tmux") version=$(tmux -V 2>/dev/null || echo "unknown") ;;
      "fzf") version="fzf $(fzf --version 2>/dev/null | cut -d' ' -f1 || echo "unknown")" ;;
      "tim") version="tim (custom script)" ;;
      esac
      echo -e "   ${GREEN}✅ $dep: $version${NC}"
    else
      echo -e "   ${RED}❌ $dep: Not found${NC}"
    fi
  done
}

# Function to test the integration
test_integration() {
  echo -e "${BLUE}🧪 Testing Tim-Tmux integration...${NC}"
  echo ""

  # Test basic tim command
  echo -e "${CYAN}Testing basic tim functionality...${NC}"
  if $TIM_CMD --help &>/dev/null; then
    echo -e "   ${GREEN}✅ Tim command works${NC}"
  else
    echo -e "   ${RED}❌ Tim command failed${NC}"
    return 1
  fi

  # Test tim tmux commands
  echo -e "${CYAN}Testing tim tmux integration commands...${NC}"
  local tmux_commands=("tmux-status" "tmux-status-color" "tmux-menu-tags")

  for cmd in "${tmux_commands[@]}"; do
    if $TIM_CMD "$cmd" &>/dev/null; then
      echo -e "   ${GREEN}✅ tim $cmd works${NC}"
    else
      echo -e "   ${YELLOW}⚠️  tim $cmd may not work properly${NC}"
    fi
  done

  # Test tmux integration if tmux is running
  if tmux list-sessions &>/dev/null; then
    echo -e "${CYAN}Testing tmux environment...${NC}"
    refresh_tmux_status

    local tim_available
    tim_available=$(tmux show-environment TIM_AVAILABLE 2>/dev/null)
    if [ $? -eq 0 ]; then
      echo -e "   ${GREEN}✅ Tmux environment variables work${NC}"
    else
      echo -e "   ${RED}❌ Tmux environment variables not accessible${NC}"
    fi
  else
    echo -e "   ${YELLOW}⚠️  Tmux not running - skipping tmux-specific tests${NC}"
  fi

  echo ""
  echo -e "${GREEN}🎉 Integration test complete!${NC}"
}

# Main function
main() {
  case "${1:-}" in
  "setup" | "install")
    setup_tmux_integration
    ;;
  "start" | "daemon")
    start_refresh_daemon
    ;;
  "stop" | "kill")
    stop_refresh_daemon
    ;;
  "status" | "info")
    show_status
    ;;
  "test" | "check")
    test_integration
    ;;
  "refresh")
    refresh_tmux_status
    echo -e "${GREEN}✅ Refreshed tmux status variables${NC}"
    ;;
  "help" | "-h" | "--help")
    echo -e "${BLUE}Tim-Tmux Integration Helper${NC}"
    echo ""
    echo -e "${CYAN}Usage:${NC} $0 <command>"
    echo ""
    echo -e "${CYAN}Commands:${NC}"
    echo -e "   ${YELLOW}setup${NC}    - Setup the integration"
    echo -e "   ${YELLOW}start${NC}    - Start refresh daemon"
    echo -e "   ${YELLOW}stop${NC}     - Stop refresh daemon"
    echo -e "   ${YELLOW}status${NC}   - Show integration status"
    echo -e "   ${YELLOW}test${NC}     - Test the integration"
    echo -e "   ${YELLOW}refresh${NC}  - Refresh tmux variables"
    echo -e "   ${YELLOW}help${NC}     - Show this help"
    ;;
  *)
    echo -e "${RED}❌ Unknown command: ${1:-}${NC}"
    echo -e "${CYAN}Run '$0 help' for usage information${NC}"
    exit 1
    ;;
  esac
}

# Run main function with all arguments
main "$@"
