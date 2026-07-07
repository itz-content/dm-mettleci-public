#!/bin/bash
export KUBECONFIG=/home/itzuser/kubeconfig
echo "Applying IBM Operator Catalog..."
oc apply -f ~/cp4d-ibm-catalogs.yml --kubeconfig=$KUBECONFIG

echo "Waiting for catalog pod to initialize..."
oc wait --for=condition=Ready pod -l olm.catalogSource=ibm-operator-catalog -n openshift-marketplace --kubeconfig=$KUBECONFIG --timeout=300s

echo "IBM Operators are now available for deployment."