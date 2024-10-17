variable "azure_rg" {
  type        = string
  description = "The resource group name"
  default     = "rg-sandbox-devops"
  validation {
    condition     = length(var.azure_rg) > 0
    error_message = "The resource group name must be declared"
  }
}

variable "rg_vnet" {
  type        = string
  description = "The Virtual Network"
  default     = "vnet-sandbox-devops"
  validation {
    condition     = length(var.rg_vnet) > 0
    error_message = "The Virtual Network name must be declared"
  }
}

variable "rg_subnet" {
  type        = string
  description = "The Virtual Network subnet"
  default     = "subnet-sandbox-devops"
  validation {
    condition     = length(var.rg_subnet) > 0
    error_message = "The Virtual Network subnet name must be declared"
  }
}


variable "common_tags" {
  type        = map(string)
  description = "Common tags"
  default = {
    created_by = "terraform-openshift-local-azure-vm"
    sandbox    = "openshift"
  }
}

variable "resource_name_sufix" {
  type        = string
  description = "The resource name sufix"
  default     = "openshift"
}

variable "additional_inbound_access" {
  type = list(object({
    name                    = string
    source_address_prefix   = optional(string, "auto") # auto means get if from data.http.myip.response_body
    destination_port_ranges = list(string)
    priority                = number
  }))
  description = "Addional inbound tcp access"
  default     = []
}

variable "ssh_private_key_file" {
  type        = string
  description = "The ssh private key for Linux VMs"
  default     = "~/.ssh/id_rsa"
}

variable "ssh_public_key_file" {
  type        = string
  description = "The ssh public key for Linux VMs"
  default     = "~/.ssh/id_rsa.pub"
}

variable "vm_size" {
  type        = string
  description = "The VM size"
  default     = "Standard_D4as_v5"
}

variable "home_disk_size_gb" {
  type        = number
  description = "The size in GB of /home disk"
  default     = 64
}
