#!/bin/bash

# Define the path to your folder
set -euo pipefail

# Load configuration variables
source ./config.sh

# -----------------------------
# Collect System Information
# -----------------------------
CPU_TOTAL=$(lscpu | awk -F: '/^CPU\(s\)/ {gsub(/^[ \t]+/, "", $2); print $2; exit}')
CPU_MODEL=$(lscpu | awk -F: '/^Model name/ {gsub(/^[ \t]+/, "", $2); print $2; exit}')
THREADS_PER_CORE=$(lscpu | awk -F: '/^Thread\(s\) per core/ {gsub(/^[ \t]+/, "", $2); print $2; exit}')
CORES_PER_SOCKET=$(lscpu | awk -F: '/^Core\(s\) per socket/ {gsub(/^[ \t]+/, "", $2); print $2; exit}')

TOTAL_MEMORY=$(free -m | awk '/^Mem:/{print $2}')
USED_MEMORY=$(free -m | awk '/^Mem:/{print $3}')
FREE_MEMORY=$(free -m | awk '/^Mem:/{print $4}')

PERCENTAGE_USED=$(( USED_MEMORY * 100 / TOTAL_MEMORY ))

SWAP_TOTAL=$(free -m | awk '/^Swap:/{print $2}')
SWAP_USED=$(free -m | awk '/^Swap:/{print $3}')

UPTIME_PRETTY=$(uptime -p | sed 's/^up //')
PROC_COUNT=$(ps -u "$USER" --no-header | wc -l)


# -----------------------------
# Ensure Log Directory and File Exists
# -----------------------------
if [ ! -d "$LOG_DIR" ]; then
    mkdir -p "$LOG_DIR"
fi

if [ ! -f "$LOG_PATH" ]; then
    touch "$LOG_PATH"
fi

# -----------------------------
# Logging Header
# -----------------------------
{
    echo ""
    echo "==========================================="
    echo "System Audit: $(date)"
    echo "==========================================="
    echo ""
} >> $LOG_PATH

echo -e  "${BLUE}Running system audit...${RESET}"

# -----------------------------
# CPU Information
# -----------------------------
echo -e "${YELLOW}Collecting CPU information...${RESET}"

{
    echo "[CPU]"
    echo "Total CPUs: $CPU_TOTAL"
    echo "Model: $CPU_MODEL"
    echo "Threads per Core: $THREADS_PER_CORE"
    echo "Cores per Socket: $CORES_PER_SOCKET"
    echo ""
} >> $LOG_PATH

# -----------------------------
#Memory Usage
# -----------------------------
echo -e "${YELLOW}Checking memory usage...${RESET}"

{
    echo "[MEMORY]"
    echo "Memory Usage Details:"
    free -h
} >> "$LOG_PATH"

#Check if memory usage exceeds the set threshold and display a worning message
if [ "$PERCENTAGE_USED" -ge "$THRESHOLD" ]; then
    MEM_STATUS="CRITICAL"

    echo -e "${RED}[CRITICAL] Memory usage is at ${PERCENTAGE_USED}% (${USED_MEMORY} MB)${RESET}"
    echo "[WARNING] Memory usage critical: ${PERCENTAGE_USED}% (${USED_MEMORY} MB)" >> $LOG_PATH 
    
    # Windows popup (WSL) 
    /mnt/c/Windows/System32/cmd.exe /c msg * "[Critical] Memory Usage: ${PERCENTAGE_USED}%" || true
    
    # Email alert
    echo "High memory usage detected: ${PERCENTAGE_USED}% on $(hostname)" \
        | mail -s "CRITICAL: Memory Alert on $(hostname)" "$ALERT_EMAIL"

else
    MEM_STATUS="HEALTHY"

    echo -e "${GREEN}[OK] Memory usage healthy: ${PERCENTAGE_USED}%${RESET}"
    echo "[INFO] Memory usage is healthy: ${PERCENTAGE_USED}%" >> $LOG_PATH
fi

echo "" >> $LOG_PATH

# -----------------------------
# Swap
# -----------------------------
{
    echo "[SWAP]"
    echo "Total Swap: $SWAP_TOTAL MB"
    echo "Used Swap: $SWAP_USED MB"
    echo ""
} >> $LOG_PATH

# -----------------------------
# Network Information
# -----------------------------
echo -e "${YELLOW}Collecting network information...${RESET}"

IP=$(ip -o -4 addr show | awk '{print $4}' | head -n 1)

{
    echo "[NETWORK]"
    echo "IP Address: $IP"
    echo ""
} >> $LOG_PATH

# -----------------------------
# System Uptime + Process Count
# -----------------------------
echo -e "${YELLOW}Checking system uptime...${RESET}"
echo -e "${YELLOW}Counting user processes...${RESET}"

{
    echo "[SYSTEM]"
    echo "Hostname: $(hostname)"
    echo "Uptime: $UPTIME_PRETTY"
    echo "Running Processes: $PROC_COUNT"
    echo ""
} >> $LOG_PATH

echo -e "${GREEN}System audit completed successfully.${RESET}"