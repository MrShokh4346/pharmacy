#!/bin/bash
export POSTGRES_PASSWORD=82e50d6eb63f

docker build -t pharma_database . && docker run -d -p 5432:5252 pharma_database