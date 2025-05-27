#!/bin/bash
# Restore script for Docker containers and volumes

BACKUP_DIR="./backups"

# List available backups
echo "Available backups:"
ls -1 "${BACKUP_DIR}" | sort -r | head -10

echo "Enter backup timestamp to restore (e.g., 20240101_120000):"
read TIMESTAMP

BACKUP_SUBDIR="${BACKUP_DIR}/${TIMESTAMP}"

if [ ! -d "${BACKUP_SUBDIR}" ]; then
    echo "Backup not found!"
    exit 1
fi

echo "Restoring from backup ${TIMESTAMP}..."

# Restore web servers
for i in 1 2 3; do
    CONTAINER_NAME="web-server-${i}"
    
    # Stop existing container
    docker stop "${CONTAINER_NAME}" 2>/dev/null
    docker rm "${CONTAINER_NAME}" 2>/dev/null
    
    # Load container image
    docker load < "${BACKUP_SUBDIR}/${CONTAINER_NAME}.tar"
    
    # Restore volume data
    docker run --rm \
        -v "docker-cloud-architecture_web${i}:/target" \
        -v "${BACKUP_SUBDIR}:/backup" \
        alpine tar xzf "/backup/volume-web${i}.tar.gz" -C /target
    
    # Run container from backup image
    docker run -d \
        --name "${CONTAINER_NAME}" \
        --network cloud-network \
        -v "docker-cloud-architecture_web${i}:/app/data" \
        "backup-${CONTAINER_NAME}:${TIMESTAMP}"
done

# Restore MySQL if backup exists
if [ -f "${BACKUP_SUBDIR}/mysql-dump.sql" ]; then
    echo "Restoring MySQL database..."
    docker exec -i mysql-db mysql -u root -prootpassword < "${BACKUP_SUBDIR}/mysql-dump.sql"
fi

echo "Restore completed successfully"