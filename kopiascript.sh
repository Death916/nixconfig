
# Ensure Kopia is in the PATH for systemd execution
PATH=/run/current-system/sw/bin:$PATH

# Exit on error
set -e

LOG_TAG="kopia-backup-nixos-server"

# --- Configuration ---
# Add full paths to directories you want to back up
DIRECTORIES_TO_BACKUP=(
  "/etc"
  "/srv"
  "/var/log"
  "/home/"
  "/var/lib/"
  "/root/"
  "/storage"
  # Be specific for home directories if not backing up all of /home
  # Add more paths as needed
)

# --- Backup Logic ---
logger -t "$LOG_TAG" "Starting Kopia backup process for NixOS server."

# Connect to repository (Kopia will use existing config if already connected and valid)
# This is a safety check; normally not needed if `kopia repository connect` was successful earlier.
# If you encounter issues, you might need to ensure the environment for systemd can find the kopia config.
# For simplicity, we assume the `sudo kopia repository connect` in Step 2 established the connection.

for dir_path in "${DIRECTORIES_TO_BACKUP[@]}"; do
  if [ -d "$dir_path" ]; then
    logger -t "$LOG_TAG" "Backing up directory: $dir_path"
    # The username and hostname from the 'connect' command will be used by default.
    # You can add specific tags for better organization.
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

