#!/bin/bash

echo "Running db.sh script..."

# Wait for PostgreSQL to be ready
until pg_isready -U "$POSTGRES_USER"; do
  echo "Waiting for PostgreSQL to be ready..."
  sleep 2
done

# Creating the database (if necessary)
createdb -U "$POSTGRES_USER" "$POSTGRES_DB"

# Apply SQL file
echo "Running SQL script to create tables..."
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /db/pharmacy.sql

echo "Database initialization complete."