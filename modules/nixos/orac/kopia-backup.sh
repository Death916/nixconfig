#!/bin/sh

# Ensure Kopia is in the PATH for systemd execution
PATH=/run/current-system/sw/bin:$PATH

# Exit on error
set -e

LOG_TAG="kopia-backup"

# --- Configuration ---
# Add full paths to directories you want to back up
DIRECTORIES_TO_BACKUP=(
  "/etc"
  "/srv"
  "/var/log"
  "/home/"
  "/var/lib/"
  "/root/"
  # Be specific for home directories if not backing up all of /home
  # Add more paths as needed
)

# --- Backup Logic ---
logger -t "$LOG_TAG" "Starting Kopia backup process for NixOS server."

#run kopia repository connect before run
for dir_path in "${DIRECTORIES_TO_BACKUP[@]}"; do
  if [ -d "$dir_path" ]; then
    logger -t "$LOG_TAG" "Backing up directory: $dir_path"
    kopia snapshot create "$dir_path" --tags "path:$dir_path"
    logger -t "$LOG_TAG" "Successfully backed up: $dir_path"
  else
    logger -t "$LOG_TAG" "Directory not found, skipping: $dir_path"
  fi
done

logger -t "$LOG_TAG" "Kopia backup process completed."

# Optional: Run Kopia maintenance (can also be a separate timer)
# logger -t "$LOG_TAG" "Running Kopia maintenance."
#kopia maintenance run --full
#logger -t "$LOG_TAG" "Kopia maintenance finished."


