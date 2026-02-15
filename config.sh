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


CPU_TOTAL=$(lscpu | awk -F: '/^CPU\(s\)/ {gsub(/^[ \t]+/, "", $2); print $2; exit}')
CPU_MODEL=$(lscpu | awk -F: '/^Model name/ {gsub(/^[ \t]+/, "", $2); print $2; exit}')
THREADS_PER_CORE=$(lscpu | awk -F: '/^Thread\(s\) per core/ {gsub(/^[ \t]+/, "", $2); print $2; exit}')
CORES_PER_SOCKET=$(lscpu | awk -F: '/^Core\(s\) per socket/ {gsub(/^[ \t]+/, "", $2); print $2; exit}')


# -----------------------------
# Memory calculations
# -----------------------------
TOTAL_MEMORY=$(free -m | awk '/^Mem:/{print $2}')
USED_MEMORY=$(free -m | awk '/^Mem:/{print $3}')
FREE_MEMORY=$(free -m | awk '/^Mem:/{print $4}')

PERCENTAGE_USED=$(( USED_MEMORY * 100 / TOTAL_MEMORY ))

SWAP_TOTAL=$(free -m | awk '/^Swap:/{print $2}')
SWAP_USED=$(free -m | awk '/^Swap:/{print $3}')

# -----------------------------
# System information
# -----------------------------
UPTIME_PRETTY=$(uptime -p | sed 's/^up //')
PROC_COUNT=$(ps -u "$USER" --no-header | wc -l)

# -----------------------------
# Terminal colors
# -----------------------------
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"