#!/usr/bin/env bash
# Function to execute Ansible playbook on Vagrant server


create_inventory() {
    echo "[all]"
    vagrant ssh-config | awk '/HostName/ {host=$2} /User / {user=$2} /Port/ {port=$2} /IdentityFile/ {key=$2} /^$/ {print host, "ansible_host="host, "ansible_user="user, "ansible_port="port, "ansible_ssh_private_key_file="key "ansible_host_key_checking=false ansible_ssh_host_key_checking=false" }'

}



run_ansible() {
    ansible-playbook -i inventory.ini playbook.yml
}

# Create Vagrantfile
cat <<EOF > Vagrantfile
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"
  config.vm.provision :shell, inline: "apt-get update"
  config.vm.provision :ansible do |ansible|
    ansible.playbook = "playbook.yml"
  end
end
EOF

# Create Ansible playbook
cat <<EOF > playbook.yml
- hosts: all
  become: true
  roles:
    - role: ../.

EOF

# Create Ansible inventory file

# Start Vagrant server
vagrant destroy --force
vagrant up
create_inventory  > inventory.ini

# Execute Ansible playbook on Vagrant server
run_ansible

# Destroy Vagrant server
vagrant destroy -f

# Return the result of the Ansible run
ansible_result=$?
exit $ansible_result
