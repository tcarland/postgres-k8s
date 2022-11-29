Postgres on Kubernetes Deployment
===================================

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
