#!/bin/bash
export POSTGRES_PASSWORD=82e50d6eb63f
export POSTGRES_USER=pharma_user
export POSTGRES_DB=pharma_db


psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -h localhost -p 5252 