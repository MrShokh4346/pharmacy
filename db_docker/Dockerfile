FROM postgres:16

RUN mkdir /db

WORKDIR /db

COPY pharmacy.sql /docker-entrypoint-initdb.d/

COPY db.sh /docker-entrypoint-initdb.d/

RUN chmod a+x /docker-entrypoint-initdb.d/db.sh

#WORKDIR src

#CMD gunicorn main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker --bind=0.0.0.0:8000