# Troubleshooting
This document is a list of solutions to possible problems with the deployed example bank program.

## Pods won't start up with a `ContainerCreationError` error
This usually means that something that the pod requires to function is not present within OpenShift. This is likely a secret.
In the GUI, go to the logs of that pod, then click on 'Events'. It should specify the secret that is expected but not present.

### Add a secret to your external secret provider (e.g. Vault)
This repo is set up to use External Secrets from a provider such as Hashicorp vault.
By default, this repo uses the `new-example-bank` directory to store secrets, which may need to be changed in your case.
You may need to check the following manifests and change the path to the secret if it doesn't match your configuration. 

```
transaction-service/transaction-service/bank-appid-secret.yaml
transaction-service/transaction-service/bank-db-secret.yaml
transaction-service/transaction-service/bank-oidc-secret.yaml
bank-knative-service/bank-knative-service/bank-oidc-adminuser.yaml
mobile-simulator/mobile-simulator/mobile-simulator-secrets.yaml
```
Make sure that each of the required secrets are added into Hashicorp vault so they can be propagated properly.

### If you don't have an external secret provider
Modification will be required to use another type of secret such as SealedSecrets or normal secrets.
Normal secrets can be manually added to each cluster, however this is insecure and time consuming.

## 500 Error when creating users or making transactions
A likely cause of this error is that the user and transaction services can not connect to the database.

### Check if a database was created 
If not, refer to [this guide](README.md#database-optional).

### Check the values of `bank-db-secret`
The `bank-db-secret` secret contains info on what the user and transaction services use to connect to the database.
1. Make sure `bank-db-secret` has been created in your k8s/OpenShift environment.
2. Check the values in the `bank-db-secret` and make sure none are missing or contain incorrect information. 
For more information on this secret and for the sample values used by the example database provided, go to [secrets.md](secrets.md#bank-db-secret).
