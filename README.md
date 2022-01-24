## Repository for demo Submariner and RHACM

All of this commands needs to be performed in the ACM Hub cluster to deploy through GitOps.

```
oc new-project bank-infra
```

* Deploy the transaction-service

```
oc apply -k transaction-service/acm-resources
```
* Deploy the user-service

```
oc apply -k user-service/acm-resources
```
* Deploy the mobile-simulator

```
oc apply -k mobile-simulator/acm-resources

```
* Deploy the bank-knative-service

```
oc apply -k bank-knative-service/acm-resources
```

* Deploy the openshift-serverless Operator

```
oc create -f serverless-operator/acm-resources/namespace.yaml
oc apply -k serverless-operator/acm-resources
```
* Cleanup

```bash
oc delete -k transaction-service/acm-resources
oc delete -k user-service/acm-resources
oc delete -k mobile-simulator/acm-resources
oc delete -k bank-knative-service/acm-resources
oc delete -k serverless-operator/acm-resources
```

<hr >

* Condensed version of all apply commands

```bash
oc apply -k transaction-service/acm-resources
oc apply -k user-service/acm-resources
oc apply -k mobile-simulator/acm-resources
oc apply -k bank-knative-service/acm-resources
```