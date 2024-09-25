FROM postgres:16

RUN mkdir /db

WORKDIR /db

COPY pharmacy.sql .

COPY db.sh .

RUN chmod a+x *.sh

#WORKDIR src

#CMD gunicorn main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker --bind=0.0.0.0:8000