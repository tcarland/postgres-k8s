Postgres on Kubernetes Deployment - v24.04.22
=============================================

Kustomize manifests for a simple example of deploying postgres to k8s.

## Configuration

Relies on three environment variables in order to build the 
kubernetes *Secret*. The *env.template* file demonstrates 
setting three vars, *POSTGRES_DB, POSTGRES_USER*, and 
*POSTGRES_PASSWORD*. Copy the template and create a custom
env file to set the vars.
```
cp env/env.template env/mydeployment.env
```

## Postgres Provisioning

The Postgres instance can be provisioned at container build by providing 
SQL scripts. The official Postgres image defines the directory 
*/docker-entrypoint-initdb.d/* for running the scripts at startup.
The provided *Dockerfile* provides an example of defining a database 
schema and user roles for accessing the database.

An example *01-schema.sql* should be idempotent in defining a schema and 
would look something like the following:
```sql
CREATE SCHEMA IF NOT EXISTS test;

CREATE TABLE IF NOT EXISTS test.file (
  fileId serial PRIMARY KEY,
  fileType char(5) NOT NULL,  
  filePath VARCHAR (250)  NOT NULL, 
  fileMD5 CHAR (32) NULL,
  fileModifiedDateTime TIMESTAMP NOT NULL,
  createDateTime TIMESTAMP NOT NULL,
  etag varchar(40),
  UNIQUE(filePath,fileModifiedDateTime)
);
```

And a sample *02-roles.sql* for defining access.
```sql
CREATE ROLE test_readonly;
GRANT CONNECT ON DATABASE mydb TO test_readonly;
GRANT USAGE ON SCHEMA test TO test_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA test TO test_readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA test GRANT SELECT ON TABLES TO test_readonly; 

CREATE USER test_user WITH PASSWORD '$TESTUSERPW';
GRANT test_readonly TO test_user;

--Creating a role with superior privileges for test tables

CREATE ROLE test_admin_role;
GRANT CONNECT ON DATABASE mydb TO test_admin_role;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA test TO test_admin_role;
GRANT USAGE,CREATE ON SCHEMA test TO test_admin_role;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA test TO test_admin_role;
--ALTER ROLE test_admin_role CREATEDB;

CREATE USER test_admin WITH PASSWORD '$TESTADMINPW';
GRANT test_admin_role TO test_admin;
ALTER SCHEMA test OWNER TO test_admin;
```

## Deployment

To deploy run kustomize on the manifests or overlay as appropriate.
```
source env/mydeployment.env
kustomize build manifests/ | kubectl apply -f -
```

Connecting locally to Postgres
```
kubectl exec -it postgres-xxxx -- psql -h localhost -U appuser --password -p 5432 mydb
```
