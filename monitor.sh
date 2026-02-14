#!/bin/bash

# Define the path to your folder
set -euo pipefail

# Load variables from config.sh
source ./config.sh

# -----------------------------
# Ensure Log Directory Exists
# -----------------------------

# If log directory and file is local to the script, create it if it doesn't exist.
if [ ! -d $LOG_DIR ]; then
    mkdir -p "$LOG_DIR"
fi

if [ ! -f $LOG_PATH ]; then
    touch $LOG_PATH
fi

<<comment
Note: If the log directory and file are located in a system directory (like /var/log),
the script will attempt to create them with sudo permissions if they don't exist, and set permissions to the current user.
This is to ensure that the script can write logs without requiring sudo every time it runs, while still maintaining proper permissions for security.

if [ ! -d $LOG_DIR ]; then
    sudo mkdir -p "$LOG_DIR"
    sudo chown $USER:$USER "$LOG_DIR"
fi

if [ ! -f $LOG_PATH ]; then
    sudo touch $LOG_PATH
    sudo chown $USER:$USER $LOG_PATH
fi
comment

# -----------------------------
# Logging Header
# -----------------------------
{
    echo "==========================================="
    echo "System Audit: $(date)"
    echo "==========================================="
} >> $LOG_PATH

echo -e  "${BLUE}Running system audit...${RESET}"

# -----------------------------
# CPU Information
# -----------------------------
echo -e "${YELLOW}Collecting CPU information...${RESET}"

lscpu | while IFS=: read -r key value; do
    case "$key" in
        "CPU(s)")
            echo "Total Number of CPUs: $value" ;;
        "CPU family")
            echo "CPU Family: $value" ;;
        "Model")
            echo "Model ID: $value" ;;
        "Thread(s) per core")
            echo "Threads per Core: $value" ;;
        "Core(s) per socket")
            echo "Core per Socket Count: $value" ;;
        "Model name")
            echo "Processor Model Name: $value" ;;
    esac
done >> $LOG_PATH

# -----------------------------
#Memory Usage
# -----------------------------
echo -e "${YELLOW}Checking memory usage...${RESET}"

{
    echo "Memory Usage Details:"
    free -h
} >> "$LOG_PATH"

#Check if memory usage exceeds the set threshold and display a worning message
if [ "$PERCENTAGE_USED" -ge "$THRESHOLD" ]; then
    echo -e "${RED}[CRITICAL] Memory usage is at ${PERCENTAGE_USED}% (${USED_MEMORY} MB)${RESET}"
    echo "[WARNING] Memory usage critical: ${PERCENTAGE_USED}% (${USED_MEMORY} MB)" >> $LOG_PATH 
    
    # Windows popup (WSL) 
    /mnt/c/Windows/System32/cmd.exe /c msg * "[Critical] Memory Usage: ${PERCENTAGE_USED}%" || true
    
    # Email alert
    echo "High memory usage detected: ${PERCENTAGE_USED}% on $(hostname)" \
        | mail -s "CRITICAL: Memory Alert on $(hostname)" "$ALERT_EMAIL"

else
    echo -e "${GREEN}[OK] Memory usage healthy: ${PERCENTAGE_USED}%${RESET}"
    echo "[INFO] Memory usage is healthy: ${PERCENTAGE_USED}%" >> $LOG_PATH
fi

# -----------------------------
# Network Information
# -----------------------------
echo -e "${YELLOW}Collecting network information...${RESET}"

IP=$(ip -o -4 addr show | awk '{print $4}' | head -n 1)

echo "Network IP: $IP" >> "$LOG_PATH"

# -----------------------------
# System Uptime
# -----------------------------
echo -e "${YELLOW}Checking system uptime...${RESET}"

echo "System Uptime: $(uptime -p)" >> $LOG_PATH

# -----------------------------
# Process Count
# -----------------------------
echo -e "${YELLOW}Counting user processes...${RESET}"

PROC_COUNT=$(ps -u "$USER" --no-header | wc -l)
echo "Number of processes: $PROC_COUNT" >> "$LOG_PATH"

echo -e "${GREEN}System audit completed successfully.${RESET}"