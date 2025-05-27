#!/bin/bash
# Automated backup script for Docker containers and volumes
# Runs every 5 minutes via cron

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_SUBDIR="${BACKUP_DIR}/${TIMESTAMP}"

# Create backup directory
mkdir -p "${BACKUP_SUBDIR}"

echo "Starting backup at ${TIMESTAMP}"

# Backup all web server containers
for i in 1 2 3; do
    CONTAINER_NAME="web-server-${i}"
    echo "Backing up ${CONTAINER_NAME}..."
    
    # Commit container to image
    docker commit "${CONTAINER_NAME}" "backup-${CONTAINER_NAME}:${TIMESTAMP}"
    
    # Export container image
    docker save "backup-${CONTAINER_NAME}:${TIMESTAMP}" > "${BACKUP_SUBDIR}/${CONTAINER_NAME}.tar"
    
    # Backup volume data
    docker run --rm \
        -v "docker-cloud-architecture_web${i}:/source" \
        -v "${BACKUP_SUBDIR}:/backup" \
        alpine tar czf "/backup/volume-web${i}.tar.gz" -C /source .
done

# Backup MySQL if exists
if docker ps | grep -q mysql-db; then
    echo "Backing up MySQL database..."
    docker exec mysql-db mysqldump -u root -prootpassword --all-databases > "${BACKUP_SUBDIR}/mysql-dump.sql"
fi

# Keep only last 10 backups (cleanup old backups)
cd "${BACKUP_DIR}"
ls -t | tail -n +11 | xargs -r rm -rf

echo "Backup completed successfully"