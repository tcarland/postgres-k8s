FROM postgres:16.4

ENV POSTGRES_DB=mydb

#COPY 01-schema.sql /docker-entrypoint-initdb.d/
#COPY 02-roles.sql /docker-entrypoint-initdb.d/
#RUN chmod 0755 /docker-entrypoint-initdb.d/01-schema.sql
#RUN chmod 0755 /docker-entrypoint-initdb.d/02-roles.sql

EXPOSE 5432
