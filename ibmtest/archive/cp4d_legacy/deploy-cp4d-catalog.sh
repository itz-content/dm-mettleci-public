#!/bin/bash
export KUBECONFIG="${HOME}/.kube/config"

echo "=========================================="
echo "Applying IBM Operator Catalog..."
echo "=========================================="
oc apply -f cp4d-ibm-catalogs.yml --kubeconfig=$KUBECONFIG

echo "Waiting for CatalogSource to become healthy..."
while true; do
    CATALOG_STATE=$(oc get catalogsource ibm-operator-catalog -n openshift-marketplace -o jsonpath='{.status.connectionState.lastObservedState}' --kubeconfig=$KUBECONFIG 2>/dev/null)
    
    if [ "$CATALOG_STATE" == "READY" ]; then
        echo "Catalog is READY."
        break
    else
        echo "Catalog status: $CATALOG_STATE (waiting)..."
        sleep 20
    fi
done