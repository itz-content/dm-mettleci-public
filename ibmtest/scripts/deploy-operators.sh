#!/bin/bash
#!/bin/bash
export KUBECONFIG=/home/itzuser/kubeconfig

echo "=========================================="
echo "1. Creating Namespaces..."
echo "=========================================="
oc create namespace ibm-common-services --kubeconfig=$KUBECONFIG
oc create namespace cp4d-operators --kubeconfig=$KUBECONFIG
oc create namespace cp4d-instance --kubeconfig=$KUBECONFIG

echo "=========================================="
echo "2. Applying Operator Group..."
echo "=========================================="
oc apply -f cp4d-operator-group.yml --kubeconfig=$KUBECONFIG

echo "Namespaces and Operator Group created successfully."