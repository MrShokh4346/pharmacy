#!/bin/bash
export POSTGRES_PASSWORD=82e50d6eb63f
export POSTGRES_USER=pharma_user
export POSTGRES_DB=pharma_db

#docker build -t pharma_database . && 
docker run -d -p 5252:5432 -e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} -e POSTGRES_USER=${POSTGRES_USER} -e POSTGRES_DB=${POSTGRES_DB} --name pharma_database pharma_database