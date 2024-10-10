# #!/bin/bash

# # su $POSTGRES_USER

# echo "Running db.sh script..."

# until pg_isready -h localhost -U "$POSTGRES_USER"; do
#   echo "Waiting for PostgreSQL to be ready..."
#   sleep 2
# done

# createdb -U $POSTGRES_USER $POSTGRES_DB

# echo "Running SQL script to create tables..."

# psql -U $POSTGRES_USER -d $POSTGRES_DB -f pharmacy.sql

# echo "Database initialization complete."