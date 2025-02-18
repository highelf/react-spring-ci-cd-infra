variable "environment" {
  type = string
}

variable "vnet_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "node_count" {
  type = number
}

variable "vm_size" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "resource_group_location" {
  type = string
}

variable "service_cidr" {
  type = string
}

variable "dns_service_ip" {
  type = string
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${var.environment}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  dns_prefix          = "aks-${var.environment}"

  default_node_pool {
    name            = "system"
    node_count      = var.node_count
    vm_size         = var.vm_size
    vnet_subnet_id  = var.subnet_id
  }

  network_profile {
    network_plugin = "azure"
    service_cidr   = var.service_cidr
    dns_service_ip = var.dns_service_ip
  }

  identity {
    type = "SystemAssigned"
  }
}

output "aks_cluster_id" {
  value = azurerm_kubernetes_cluster.aks.id
}

output "aks_kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}
