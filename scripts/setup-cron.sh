#!/bin/bash
# Setup cron job for automatic backups every 5 minutes

SCRIPT_PATH="./scripts/backup.sh"

# Make backup script executable
chmod +x "${SCRIPT_PATH}"

# Add cron job (backup every 5 minutes)
(crontab -l 2>/dev/null; echo "*/5 * * * * ${SCRIPT_PATH} >> /var/log/docker-backup.log 2>&1") | crontab -

echo "Cron job configured for automatic backups every 5 minutes"