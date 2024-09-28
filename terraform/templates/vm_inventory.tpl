all:
  vars:
    ansible_connection: ssh
    ansible_user: ${admin_username}
    ansible_ssh_private_key_file: ${ssh_private_key_file}
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
  children:
    vms:
      hosts:
        ${name}:
          ansible_host: ${ip}
          ansible_port: 22
          ansible_python_interpreter: /usr/bin/python
          lun: ${home_disk_lun}
