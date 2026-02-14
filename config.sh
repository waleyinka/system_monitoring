#!/bin/bash

# -----------------------------
# Directory for logs
# -----------------------------
# LOG_PATH="/var/log/system_logs/system_logs.log"
LOG_DIR="$(dirname "$0")/logs"
LOG_PATH="$LOG_DIR/system_logs.log"

# -----------------------------
# Memory threshold
# -----------------------------
THRESHOLD=80

# -----------------------------
# Email for alerts
# -----------------------------
ALERT_EMAIL="iamomowale@outlook.com"

# -----------------------------
# Memory calculations
# -----------------------------
TOTAL_MEMORY=$(free -m | awk '/^Mem:/{print $2}')
USED_MEMORY=$(free -m | awk '/^Mem:/{print $3}')
PERCENTAGE_USED=$(echo "scale=2; $USED_MEMORY / $TOTAL_MEMORY * 100" | bc | cut -d. -f1)

# -----------------------------
# Terminal colors
# -----------------------------
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"