#!/bin/bash

# Define variables
BACKUP_DIR="/backup"
DATE=$(date +'%Y%m%d_%H%M%S')
BACKUP_FILE="$BACKUP_DIR/$DB_NAME"_"$DATE".sql

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Perform the backup using pg_dump
pg_dump -h pg_backup_container -U $DB_USER -d $DB_NAME -f $BACKUP_FILE

#pg_dump -U $DB_USER -h $DB_HOST -F c $DB_NAME > $BACKUP_FILE

# Optionally, compress the backup
gzip $BACKUP_FILE

source /backup/backup_sender.sh
#echo "$BACKUP_FILE.gz" "$DATE"
send_file "$BACKUP_FILE.gz" "$DATE"

# Optionally, remove old backups (older than 7 days in this example)
find $BACKUP_DIR -type f -name "*.gz" -mtime +7 -exec rm {} \;

echo "Backup completed: $BACKUP_FILE.gz"
