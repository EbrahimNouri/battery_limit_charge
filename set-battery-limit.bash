#!/usr/bin/env bash
set -e

CONFIG_FILE="/etc/battery_limit.conf"

# 1. Print Help Function (Defined first so it can run unconditionally)
show_help() {
    echo "ASUS TUF Battery Charge Limit Control"
    echo "=========================================="
    echo "Usage: sudo set-battery-limit [option/percentage]"
    echo ""
    echo "Options:"
    echo "  [1-100]       Set a custom battery charge limit percentage."
    echo "  default, 100  Reset battery to normal behavior (charges up to 100%)."
    echo "  -h, --help    Show this help menu screen."
    echo ""
    echo "Examples:"
    echo "  sudo set-battery-limit 60       (Stops charging at 60% permanently)"
    echo "  sudo set-battery-limit default  (Restores normal full 100% charging)"
    echo "  sudo set-battery-limit          (Shows current active limit state)"
}

# 2. Check for help flags immediately before root or hardware checks
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    show_help
    exit 0
fi

# Ensure the script runs with root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Error: Please run this script with sudo." >&2
    exit 1
fi

# 3. Smart Hardware Detection (Checks ASUS paths, BAT0, BAT1, BATT)
TARGET_FILE=""
POSSIBLE_PATHS=(
    "/sys/class/leds/asus::charge_control_end_threshold"
    "/sys/class/power_supply/BAT0/charge_control_end_threshold"
    "/sys/class/power_supply/BAT1/charge_control_end_threshold"
    "/sys/class/power_supply/BATT/charge_control_end_threshold"
)

for path in "${POSSIBLE_PATHS[@]}"; do
    if [ -f "$path" ]; then
        TARGET_FILE="$path"
        break
    fi
done

# If no path is found, throw error
if [ -z "$TARGET_FILE" ]; then
    echo "Error: Your hardware does not support a charge limit threshold." >&2
    echo "Please ensure your kernel is up to date and your laptop supports battery health charging." >&2
    exit 1
fi

# 4. Handle status check (no arguments)
if [ -z "$1" ]; then
    CURRENT_LIMIT=$(cat "$TARGET_FILE")
    echo "Current charge limit is: ${CURRENT_LIMIT}%"
    echo "Run 'sudo set-battery-limit --help' for more options."
    exit 0
fi

# 5. Handle default state
if [ "$1" == "default" ] || [ "$1" == "100" ]; then
    echo "100" > "$TARGET_FILE"
    echo "100" > "$CONFIG_FILE"
    echo "Success: Battery limit reset to default (100% full charge)."
    exit 0
fi

# 6. Validate custom number input
LIMIT="$1"
if ! [[ "$LIMIT" =~ ^[0-9]+$ ]] || [ "$LIMIT" -lt 1 ] || [ "$LIMIT" -gt 100 ]; then
    echo "Error: Invalid argument." >&2
    echo ""
    show_help
    exit 1
fi

# 7. Apply custom limit
echo "$LIMIT" > "$TARGET_FILE"
echo "$LIMIT" > "$CONFIG_FILE"
echo "Success: Battery charge limit set to ${LIMIT}%"
