# Bash System Monitor

*A Step by Step Introduction to Practical Bash Scripting*


## Overview

This project is a hands-on introduction to Bash scripting through a real world use case: building a simple system monitoring tool from scratch.

Instead of learning Bash through isolated commands, this project shows how linux commands come together to solve a practical problem.
The script collects system information, evaluates memory usage, logs results, and raises alerts when thresholds are exceeded.

It is designed especially for learners who want to move from “I know a few commands” to “I can build something useful with Bash.”


## What This Project Does

Each time the script runs, it performs a lightweight system audit that:

 - Reads CPU information
 - Checks memory usage and calculates how much is being used
 - Writes results into a structured log file
 - Displays color coded feedback in the terminal
 - Raises alerts when memory crosses a defined threshold  
 - Captures network details, uptime, and running process counts

Over time, the logs form a simple history of how the system behaves.


## Project Structure

```bash
project-folder/
│
├── config.sh
├── monitor.sh
└── logs/
```

### `config.sh`

This file holds everything I might want to change without touching the main logic.

It defines:

 - Where logs should be stored
 - The memory usage threshold for alerts
 - The email address for notifications
 - Calculated memory metrics
 - Terminal color settings for readable output

Keeping these values separate made the script easier to reason about and safer to modify.

### `monitor.sh`

This is the main script that performs the system check. It:
 - Loads values from the configuration file
 - Ensures required folders and files exist before running
 - Collects CPU and memory data
 - Appends results to a log file
 - Displays friendly status messages in the terminal
 - Triggers alerts when thresholds are exceeded

This is where everything comes together.


## How It Works

### 1. Load Configuration

The script begins by sourcing `config.sh` so all settings are available.

This keeps the logic clean and avoids hardcoding values in multiple places.

### 2. Prepare the Environment

Before doing anything else, the script checks whether the log directory and file already exist.
If not, it creates them automatically.

This means the script can run safely even on a brand new setup.

### 3. Capture System Information

The monitor gathers data using built in Linux tools:
 - `lscpu` for processor details
 - `free` for memory statistics
 - `ip` for network information
 - `uptime` for system runtime
 - `ps` for process counts

Each command contributes a small but useful part of the system snapshot.

### 4. Calculate Memory Usage

Memory usage is calculated as a percentage of used versus total memory.

This makes it easy to decide whether the system is healthy or under pressure.

### 5. Log Results

Every run appends a timestamped section to the log file:

```bash
===========================================
System Audit: 2026-02-15 20:32:18 (Example)
===========================================

[CPU]
Total CPUs: 8
Model: Intel Core i5 Series
Threads per Core: 2
Cores per Socket: 4

[MEMORY]
Memory Usage Details:
               total        used        free      shared  buff/cache   available
Mem:           8.0Gi       3.0Gi       4.0Gi       7.0Mi       400Mi       4.5Gi
Swap:          2.0Gi          0B       2.0Gi
[INFO] Memory usage is healthy: 39%

[SWAP]
Total Swap: 2 GB
Used Swap: 0 GB

[NETWORK]
IP Address: localhost (127.0.0.1)

[SYSTEM]
Hostname: local-machine
Uptime: ~1 day
Running Processes: ~40

[INFO] System metrics collected successfully.
Log written to: logs/system_monitor.log
```

This creates a running history instead of overwriting previous checks.

### 6. Alert When Threshold Is Exceeded

If memory usage rises above the configured threshold, the script:

 - Prints a clear warning in the terminal
 - Optionally sends an email notification
 - Can display a system message when running under WSL

This turns the script into an active monitor rather than just a report.


## Running the Project

Make the scripts executable:

```bash
chmod +x config.sh monitor.sh
```

Run the monitor manually:

```bash
./monitor.sh
```

After running, check the logs directory to see the generated output.


## Automating the Monitor

To run the script automatically, schedule it using cron.

Example: run every 10 minutes

```bash
*/10 * * * * /path/to/monitor.sh
```

Now the system checks itself quietly in the background.


## Example Use Cases

 - Learning Bash through a real, understandable project
 - Keeping an eye on a personal development machine
 - Exploring how Linux tools can be composed into workflows
 - Building confidence before tackling larger automation tasks


## What I Learned From This

 - How to work with command substitution and variables
 - How to safely create and manage files in scripts
 - How to parse command output using tools like awk
 - Why defensive scripting matters
 - How to design scripts that are readable and maintainable

Most importantly, I learned that Bash becomes far less intimidating once you use it to build something that matters to you.


## Possible Improvements

 - Add disk usage monitoring
 - Export logs into structured formats like CSV or JSON
 - Integrate notifications with messaging tools
 - Generate periodic summary reports
 - Expand checks to include additional system metrics


## Final Thoughts

Before this project, Bash felt like a collection of scattered tricks.

After building this, it feels like a language for talking directly to the operating system.

If you are learning Bash, my advice is simple:

 - Build something small.
 - Let it be useful.
 - Then keep improving it.

That is where understanding really starts.