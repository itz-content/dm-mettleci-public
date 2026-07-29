#!/bin/bash

# 1 & 2. Rename the downloaded key
mv ~/Downloads/vm_ssh_key.vm ~/Downloads/cp4d_ssh_key.vm 2>/dev/null

# 3. Lock down permissions
chmod 600 ~/Downloads/cp4d_ssh_key.vm

# 3.5. Prompt for the full string and extract the 2nd word (the endpoint)
read -p "Paste the full Bastion SSH Connection string: " full_ssh_string
export ITZ_API_ENDPOINT=$(echo $full_ssh_string | awk '{print $2}')

echo "Endpoint parsed as: $ITZ_API_ENDPOINT"

# 4. Create remote .kube directory and copy the config file
echo "Transferring kubeconfig to bastion..."
ssh -p 10022 -o IdentitiesOnly=yes -o StrictHostKeyChecking=no -i ~/Downloads/cp4d_ssh_key.vm $ITZ_API_ENDPOINT "mkdir -p ~/.kube"
scp -P 10022 -o IdentitiesOnly=yes -o StrictHostKeyChecking=no -i ~/Downloads/cp4d_ssh_key.vm ~/Downloads/conf_kubeconfig_download.conf $ITZ_API_ENDPOINT:~/.kube/config

# Transfer AWS credentials
scp -P 10022 -o IdentitiesOnly=yes -o StrictHostKeyChecking=no -i ~/Downloads/cp4d_ssh_key.vm ~/Downloads/secrets.aws $ITZ_API_ENDPOINT:~/secrets.aws


echo "✅ Local prep and transfer complete. You can now proceed to the VM Remote Console to access the bastion."