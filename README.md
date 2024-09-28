# Red Hat OpenShift local on Azure VM

Running Red Hat OpenShift local on Azure virtual machine 

## Requirementes

* Download the [latest release of Red Hat OpenShift Local](https://console.redhat.com/openshift/create/local) and save the files `crc-linux-amd64.tar.xz` and `pull-secret.txt` in the folder `ansible/files`
* [Terraform](https://www.terraform.io/)
* [Ansible](https://www.ansible.com/)

## Setup

1. Set the followin enviroment variables:
   - `ARM_CLIENT_ID`
   - `ARM_CLIENT_SECRET`
   - `ARM_SUBSCRIPTION_ID`
   - `ARM_TENANT_ID`

2. ```bash
   $ cd terraform
   $ terraform fmt --recursive --check .
   $ terraform init
   $ terraform validate
   $ terraform apply
   $ cd ..
   ```
2. ```bash
   $ cd ansible
   $ ansible-playbook -i inventories main.yaml
   $ cd ..
   ```

The crc log is avaliable in the file `$HOME/.crc/crc.log` in the remote VM

On local `/etc/hosts`:

```bash
XXX.XXX.XXX.XXX api.crc.testing console-openshift-console.apps-crc.testing default-route-openshift-image-registry.apps-crc.testing oauth-openshift.apps-crc.testing
```
Where `XXX.XXX.XXX.XXX` is the VM public IP

## Cleanup 

```bash
$ cd terraform
$ terraform destroy 
```

## References

[Red Hat OpenShift Local](https://docs.redhat.com/en/documentation/red_hat_openshift_local)

[Change the domain for CRC](https://github.com/crc-org/crc/wiki/Change-the-domain-for-CRC)

[OpenShift Local CRC From Another Machine](https://akos.ma/blog/openshift-local-crc-from-another-machine/)
