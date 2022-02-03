# External Secrets Specifications
This document will outline the values needed for the external secrets used by this application.

There are 5 key-value secrets total which needed to be created, each with their own values.
They are:
- `bank-db-secret`
- `bank-oidc-secret`
- `mobile-simulator-secrets`
- `bank-oidc-adminuser` (soon to be removed)
- `bank-appid-secret` (soon to be removed)

## `bank-db-secret`
Note: It is suggested to set these values to the example value if you plan on using the included sample database. Otherwise, fill out the secrets with the information required for your Postgres compatible databsase (e.g. CockroachDB, CrunchyDB etc...)
|Key|Value|Example|
|-|-|-|
|`DB_DATABASENAME`|Name of the database|`example`|
|`DB_USER`|Username used to connect to the database|`postgres`|
|`DB_PASSWORD`|Password to the database|`postgres`|
|`DB_PORTNUMBER`|Port number to connect to the database|`5432`|
|`DB_SERVERNAME`|URL to connect to the database (Internal k8s name or otherwise)|`creditdb`|
## `bank-oidc-secret`
These secrets are tricky to get right. You will find the user and transaction service wil complain in their logs if one of these values are wrong, and will suggest correct values.
|Key|Value|Example|
|-|-|-|
|`OIDC_AUDIENCES`|Name of the client used by the microservices to talk to RHSSO regarding account verification (use example value)|`account`|
|`OIDC_ISSUERIDENTIFIER`|URL used to authenticate user accounts with RHSSO|`https://keycloak.my-app.local/auth/realms/banksso`|
|`OIDC_JWKENDPOINTURL`|URL containing the public certificates of the client used by RHSSO|`https://keycloak.my-app.local/auth/realms/banksso/protocol/openid-connect/certs`|

The `OIDC_JWKENDPOINTURL` value can be found by going to a URL similar to: https://keycloak.my-app.local/auth/realms/banksso/.well-known/openid-configuration

## `mobile-simulator-secrets`
|Variable Name|Description|Example|
|-|-|-|
|`APP_ID_CLIENT_ID`|Name of the client in RHSSO|`nodeclient`|
|`APP_ID_CLIENT_SECRET`|Secret used by the client service account in RHSSO|`f1661a24-85cc-81ad-0094-ab3d202566b4`|
|`APP_ID_TOKEN_URL`|URL of the RHSSO API endpoint for getting login tokens (without the `/login`)|`https://keycloak.my-app.local/auth/realms/banksso/protocol/openid-connect`|
|`PROXY_TRANSACTION_MICROSERVICE`|Local k8s URL pointing to the transaction microservice (use example value)|`transaction-service:9080`|
|`PROXY_USER_MICROSERVICE`|Local k8s URL pointing to the user microservice (use example value)|`user-service:9080`|

## Others
`bank-oidc-adminuser` and `bank-appid-secret` are no longer needed and will be removed soon. For now, these values can be set to anything.
