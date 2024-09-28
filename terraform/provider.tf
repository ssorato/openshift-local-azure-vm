terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.3.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.5"
    }
  }
}

provider "azurerm" {
  features {}
}
