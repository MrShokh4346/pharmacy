#!/bin/bash

su $POSTGRES_USER

createdb -U $POSTGRES_USER $POSTGRES_DB

psql -U $POSTGRES_USER -d $POSTGRES_DB -f pharmacy.sql
