locals {
  inbound_access = concat(
    [
      {
        name                    = "internal-ssh"
        source_address_prefix   = "VirtualNetwork"
        destination_port_ranges = ["22"]
        priority                = 100
      },
      {
        name                    = "external-ssh"
        source_address_prefix   = "auto"
        destination_port_ranges = ["22"]
        priority                = 101
      },
      {
        name                    = "external-openshift"
        source_address_prefix   = "auto"
        destination_port_ranges = ["80","443","6443"]
        priority                = 102
      }
    ], var.additional_inbound_access
  )
}

resource "azurerm_network_security_group" "vm_nsg" {
  name                = format("nsg-%s", var.resource_name_sufix)
  location            = data.azurerm_resource_group.azure_rg.location
  resource_group_name = data.azurerm_resource_group.azure_rg.name

  dynamic "security_rule" {
    for_each = local.inbound_access
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_ranges    = security_rule.value.destination_port_ranges
      source_address_prefix      = security_rule.value.source_address_prefix == "auto" ? "${chomp(data.http.myip.response_body)}/32" : security_rule.value.source_address_prefix
      destination_address_prefix = "VirtualNetwork"
    }
  }

  tags = merge(
    {
      name = "nsg-vmpoc"
    },
    var.common_tags
  )
}

resource "azurerm_public_ip" "vm_public_ip" {
  name                = format("public-ip-%s", var.resource_name_sufix)
  location            = data.azurerm_resource_group.azure_rg.location
  resource_group_name = data.azurerm_resource_group.azure_rg.name
  allocation_method   = "Static"
  sku                 = "Basic"
  zones               = []
  tags = merge(
    {
      name = format("public-ip-%s", var.resource_name_sufix)
    },
    var.common_tags
  )
}

resource "azurerm_network_interface" "vm_nic" {
  name                = format("nic-%s", var.resource_name_sufix)
  location            = data.azurerm_resource_group.azure_rg.location
  resource_group_name = data.azurerm_resource_group.azure_rg.name

  ip_configuration {
    name                          = format("nic-config-%s", var.resource_name_sufix)
    subnet_id                     = data.azurerm_subnet.rg_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
  }

  tags = merge(
    {
      name = format("nic-%s", var.resource_name_sufix)
    },
    var.common_tags
  )
}

resource "azurerm_network_interface_security_group_association" "vm_nic_nsg" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = format("vm-%s", var.resource_name_sufix)
  location            = data.azurerm_resource_group.azure_rg.location
  resource_group_name = data.azurerm_resource_group.azure_rg.name
  network_interface_ids = [
    azurerm_network_interface.vm_nic.id
  ]
  size = var.vm_size

  os_disk {
    name                 = "osdisk-vmpoc"
    caching              = "ReadOnly"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Oracle"
    offer     = "Oracle-Linux"
    sku       = "ol94-lvm-gen2"
    version   = "9.4.4"
  }

  computer_name                   = format("vm-%s", var.resource_name_sufix)
  admin_username                  = "sandbox"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "sandbox"
    public_key = file(var.ssh_public_key_file)
  }

  tags = merge(
    {
      name = format("vm-%s", var.resource_name_sufix)
    },
    var.common_tags
  )
}

resource "azurerm_managed_disk" "home_disk" {
  name                 = format("home-%s", var.resource_name_sufix)
  location             = data.azurerm_resource_group.azure_rg.location
  resource_group_name  = data.azurerm_resource_group.azure_rg.name
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.home_disk_size_gb

  tags = merge(
    {
      name = format("home-%s", var.resource_name_sufix)
      vm   = azurerm_linux_virtual_machine.vm.name
    },
    var.common_tags
  )
}

resource "azurerm_virtual_machine_data_disk_attachment" "home_disk_attach" {
  managed_disk_id    = azurerm_managed_disk.home_disk.id
  virtual_machine_id = azurerm_linux_virtual_machine.vm.id
  lun                = 10
  caching            = "ReadWrite"
}