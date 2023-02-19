#cloud-config
# Ensure the Package Manager is up to date
package_update: true
# Install the cowsay packages
packages:
- cowsay
# Run a command which injects the cowsay on login script into the appropriate folder so it will work for all users
runcmd:
- echo cowsay hello '$USER' >>/etc/profile.d/cowsay.sh
# Create the two desired users, note these are currently using the same public key
users:
  - name: freddy
    groups: [ wheel ]
    sudo:     
      - "ALL=(ALL) NOPASSWD:ALL"
    shell: /bin/bash
    ssh-authorized-keys: 
    - ${user_data_key} # This will pick up your public key from the terraform variables
  - name: ubuntu
    groups: [ wheel ]
    sudo:     
      - "ALL=(ALL) NOPASSWD:ALL"
    shell: /bin/bash
    ssh-authorized-keys: 
    - ${user_data_key} # This will pick up your public key from the terraform variables