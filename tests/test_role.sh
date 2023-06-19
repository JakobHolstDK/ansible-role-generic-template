#!/usr/bin/env bash
# Function to execute Ansible playbook on Vagrant server
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
  tasks:
    - name: Execute Ansible role
      include_role:
        name: your_role_name
EOF

# Create Ansible inventory file
cat <<EOF > inventory.ini
[all]
vagrant ansible_host=127.0.0.1 ansible_user=vagrant ansible_ssh_private_key_file=.vagrant/machines/default/virtualbox/private_key
EOF

# Start Vagrant server
vagrant up

# Execute Ansible playbook on Vagrant server
run_ansible

# Destroy Vagrant server
vagrant destroy -f

# Return the result of the Ansible run
ansible_result=$?
exit $ansible_result
