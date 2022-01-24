#!/bin/bash

oc -n submariner-operator scale deploy submariner-addon --replicas=0
oc patch Submariner submariner --type='merge' -p $'spec:\n natEnabled: false' -n submariner-operator
oc -n submariner-operator scale deploy submariner-addon --replicas=1


