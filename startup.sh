#!/bin/bash

# cd app

# alembic upgrade head

# cd ../

gunicorn app.main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker --bind=0.0.0.0:8000