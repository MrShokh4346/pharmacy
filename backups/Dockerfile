FROM postgres:latest

# Install cron
RUN apt-get update && apt-get install -y cron

RUN mkdir /backups

WORKDIR /backups


# Copy the backup script
COPY backup.sh .
COPY backup_sender.sh .



# Copy crontab file to cron.d
COPY crontab /etc/cron.d/pg_backup_cron

RUN chmod +x backup.sh && chmod +x backup_sender.sh && chmod 0644 /etc/cron.d/pg_backup_cron

# Apply cron job
RUN crontab /etc/cron.d/pg_backup_cron

# Run cron in the foreground
CMD ["cron", "-f"]