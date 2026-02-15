#!/bin/bash

# Define the path to your folder
set -euo pipefail

# Load variables from config.sh
source ./config.sh

# -----------------------------
# Ensure Log Directory and File Exists
# -----------------------------

# If log directory and file is local to the script, create it if it doesn't exist.
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