# Example bank app deployment scripts for RHACM
This repo contains the scripts needed to automatically deploy the [akiyamn/example-bank](https://github.com/akiyamn/example-bank) app to Openshift clusters via RHACM.

## Introduction
The purpose of this repo is to provide an easy and automated way of deploying the [akiyamn/example-bank](https://github.com/akiyamn/example-bank) to Red Hat Advanced Cluster Management (RHACM) which will then automatically deploy on the Openshift clusters that RHACM is controlling. The deployment is done by using precompiled binaries hosted on quay.io. For the source: visit [akiyamn/example-bank](https://github.com/akiyamn/example-bank).

## Prerequisites
- A hub cluster running RHACM
- At least one cluster that is managed by RHACM
- A working instance of RHSSO or Keycloak (for logins)
- A vault to store external secrets such as Hashicorp Vault
- The `oc` command-line tool

## Installation

### Forking the repo (optional)
It is possible to install the example bank app without cloning or forking this repo. This is simpler, however you won't have the freedom to match keys and values to your situation. As this repo is designed for use on RHACM, the Channel and Subscription objects attempt to pull the YAML resources from a git repo. It is set-up to pull from this exact repo, referring to it via URL. You must change this if you intend to use your own fork.

#### Change the GitHub URL and branch
If forking this repo, you must change the value of `spec/pathname` in each of the following files:
```
user-service/acm-resources/channel.yaml
transaction-service/acm-resources/channel.yaml
mobile-simulator/acm-resources/channel.yaml
bank-knative-service/acm-resources/channel.yaml
```
By default, the branch in this GitHub that the Channel and Subscription objects pull from is set to: `main`.
If needed, you can change this by editing this part:
```yaml
metadata:
  annotations:
    apps.open-cluster-management.io/git-branch: YOUR-BRANCH-NAME-HERE
```
of the following files:
```
user-service/acm-resources/subscription.yaml
transaction-service/acm-resources/subscription.yaml
mobile-simulator/acm-resources/subscription.yaml
bank-knative-service/acm-resources/subscription.yaml
```

### External Secrets
This application uses external secrets stored in a vault such as a Hashicorp Vault for configuration.
They must be manually created in the vault application and set with appropriate values.
For more information: see [secrets.md](secrets.md).

### Application

All of these commands need to be performed in the RHACM Hub cluster to deploy through GitOps.

Create the bank-infra project
```bash
oc new-project bank-infra
```

Deploy the four microservices that make up the application.
*i.e. the transaction-service, user-service, mobile-simulator and bank-knative-service*

```bash
oc apply -k transaction-service/acm-resources
oc apply -k user-service/acm-resources
oc apply -k mobile-simulator/acm-resources
oc apply -k bank-knative-service/acm-resources
```

### RHSSO Setup
The app uses Red Hat Single Sign On (RHSSO) but can also be used with Keycloak (the upstream community version of the project). It uses this service to identify and authenticate users.

#### Automatic
The automatic process uses a Job object which pull a container from [this quay.io repo](https://quay.io/repository/alexocc/bank-rhsso-config). Its source is available from [akiyamn/rhsso-auto-deploy](https://github.com/akiyamn/rhsso-auto-deploy).

Log into OpenShift and apply the Job as follows:
```bash
oc apply rhsso-config
```
This should create the Job and also the External Secret object it references. For reference on the secrets used by the Job, please see [this section of secrets.md](secrets.md#bank-rhsso-secrets).

If you would prefer to use a normal secret or simply hard-code the environment variables required by the Job, edit `rhsso-config/bank-rhsso-config-job.yaml`.

#### Manual

- Open your RHSSO management console and login as an admin using in the master realm.
- Click "Create New Realm" and click "Import".
- Select the `rhsso-config/realm-export` file.

This should create a realm called `banksso` and a client within that realm called `nodeclient`.
The client should have "Service Accounts Enabled" enabled. It also should have the Service Account Role of `manage-users` under the client role of `realm-management`.

This can be verified as so:
![](https://i.imgur.com/ysWVq7g.png)

### Database (optional)
The goal of this application is to use a distributed Postgres database service such as CockroachDB or CrunchyDB. However, a script to deploy a basic Postgres instance for testing (or a single cluster) is provided. To deploy it, log into each of your managed clusters and run:

```bash
database-init/db-init.sh
```

This will spin up a basic PostgresDB instance from a template. 

#### Secret values for sample database
If you run this script, you must set the following values in an external secret called `bank-db-secret`.

|Key|Value|
|-|-|
|DB_DATABASENAME|example|
|DB_PASSWORD|postgres|
|DB_PORTNUMBER|5432|
|DB_SERVERNAME|creditdb|
|DB_USER|postgres|

Or as base64 yaml:

```yaml
DB_DATABASENAME: ZXhhbXBsZQ==
DB_PASSWORD: cG9zdGdyZXM=
DB_PORTNUMBER: NTQzMg==
DB_SERVERNAME: Y3JlZGl0ZGI=
DB_USER: cG9zdGdyZXM=
```

## Cleanup

The following commands will reverse the actions of deploying the application. Run them in the hub cluster as before.

```bash
oc delete -k transaction-service/acm-resources
oc delete -k user-service/acm-resources
oc delete -k mobile-simulator/acm-resources
oc delete -k bank-knative-service/acm-resources
```
