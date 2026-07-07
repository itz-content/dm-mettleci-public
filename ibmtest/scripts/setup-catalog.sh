#!/bin/bash
echo "Applying IBM Operator Catalog..."
oc apply -f ~/ibm-catalogs.yml --kubeconfig=/home/itzuser/kubeconfig

echo "Waiting for catalog pod to initialize..."
oc wait --for=condition=Ready pod -l olm.catalogSource=ibm-operator-catalog -n openshift-marketplace --kubeconfig=/home/itzuser/kubeconfig --timeout=300s

echo "IBM Operators are now available for deployment."