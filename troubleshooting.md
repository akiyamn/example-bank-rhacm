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
Make sure that each of the required secrets are added into Hashicorp Vault so they can be propagated properly.

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
3. After updating the values, restart the user and transaction service pods.
For more information on this secret and for the sample values used by the example database provided, go to [secrets.md](secrets.md#bank-db-secret).

## 401 Error when creating users or making transactions
This error is caused by two factors:
1. Invalid values in the `mobile-simulator-secrets` secret read by the backend services
2. X.509 certificate used by RHSSO is untrusted by the backend services

### Look in the logs first
Check the log files for a pod in either `user-service` or `transaction-service`. 
If you see some long errors in one of the services, save the logs to your computer for reference.
You should see some errors that may look like the following:

### SSL_HANDSHAKE_ERROR
You may see an error that looks like this:
```
[ERROR   ] CWPKI0823E: SSL HANDSHAKE FAILURE:  A signer with SubjectDN [CN=your-domain-here.cloud] was sent from the host [keycloak-sso.your-domain-here.cloud:443].  The signer might need to be added to local trust store [/opt/ol/wlp/usr/servers/defaultServer/resources/security/digicert-root-ca.jks], located in SSL configuration alias [defaultSSLConfig].
```
This means that the X.509 certificate used by RHSSO is untrusted by the backend services. You will either need to provide a certificate trusted by DigiCert (very expensive) or need to recompile the `user-service` and `transaction-service` with an updated `digicert-root-ca.jks` file that includes the certificate authority used by your RHSSO. Please refer to [akiyamn/example-bank](https://github.com/akiyamn/example-bank) to do so. 

### The MicroProfile JWT feature encountered an error while creating a JWT
If you encounter an error like this: 
```
[ERROR   ] CWWKS5524E: The MicroProfile JWT feature encountered an error while creating a JWT by using the [jwt] configuration and the token included in the request. CWWKS6031E: The JSON Web Token (JWT) consumer [jwt] cannot process the token string. CWWKS6023E: The audience [[account]] of the provided JSON web token (JWT) is not listed as a trusted audience in the [jwt] JWT configuration. The trusted audiences are [[something]]. 
```
it means that the value of `APP_ID_CLIENT_ID` in `mobile-simulator-secrets` is missing or incorrect.
Set the value of `APP_ID_CLIENT_ID` to whatever is provided in the **first** set of double square brackets in the error message. This is likely to be the value: `account`.
This value is meant to specify the client within RHSSO which constantly authenticates the user while using the app.