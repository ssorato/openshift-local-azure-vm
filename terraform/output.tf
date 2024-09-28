output "private_ip" {
  value       = azurerm_network_interface.vm_nic.private_ip_address
  description = "The VM private IP"
}

output "public_ip" {
  value       = azurerm_public_ip.vm_public_ip.ip_address
  description = "The VM public IP"
}

resource "local_file" "ansible-inventory" {
  content = templatefile("templates/vm_inventory.tpl",
    {
      admin_username       = "sandbox"
      ssh_private_key_file = var.ssh_private_key_file
      name                 = azurerm_linux_virtual_machine.vm.name
      ip                   = azurerm_public_ip.vm_public_ip.ip_address
      home_disk_lun        = azurerm_virtual_machine_data_disk_attachment.home_disk_attach.lun
    }
  )
  filename             = "../ansible/inventories/tf_${azurerm_linux_virtual_machine.vm.name}.yaml"
  directory_permission = "0755"
  file_permission      = "0644"
}
