#!/bin/bash
export KUBECONFIG=/home/itzuser/kubeconfig

echo "=========================================="
echo "Initializing Operator Infrastructure..."
echo "=========================================="

# 1. Create namespaces
for ns in cp4d-operators cp4d-instance; do
    if ! oc get namespace $ns >/dev/null 2>&1; then
        echo "Creating namespace: $ns"
        oc create namespace $ns
    else
        echo "Namespace '$ns' already exists."
    fi
done

# 2. Pre-seed the Scope ConfigMap
if ! oc get configmap namespace-scope -n cp4d-operators >/dev/null 2>&1; then
    echo "Creating namespace-scope ConfigMap..."
    oc create configmap namespace-scope -n cp4d-operators \
      --from-literal=namespaces=cp4d-operators,cp4d-instance --kubeconfig=$KUBECONFIG
else
    echo "ConfigMap 'namespace-scope' already exists. Skipping."
fi

# 3. Apply the OperatorGroup
echo "Applying OperatorGroup..."
oc apply -f cp4d-operator-group.yml --kubeconfig=$KUBECONFIG