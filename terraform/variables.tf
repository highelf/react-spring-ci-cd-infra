variable "environment" {
  type    = string
  default = "dev" # Change to test/prod as needed
}

variable "resource_group_name" {
  type    = string
  default = "myResourceGroup"
}

variable "location" {
  type    = string
  default = "West Europe"
}

variable "vnet_id" {
  type    = string
  default = "myVnetId"
}

variable "vnet_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "aks_node_count" {
  type = map(number)
  default = {
    dev  = 1
    test = 1
    prod = 3
  }
}

variable "aks_vm_size" {
  type = map(string)
  default = {
    dev  = "Standard_D2_v2"
    test = "Standard_D2_v2"
    prod = "Standard_D4_v2"
  }
}

variable "aks_service_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "aks_dns_service_ip" {
  type    = string
  default = "10.1.0.10"
}

variable "mysql_sku" {
  type = map(string)
  default = {
    dev  = "B_Standard_B2s"
    test = "B_Standard_B2s"
    prod = "GP_Standard_D2ds_v4"
  }
}

variable "key_vault_name" {
  type    = string
  default = "myKeyVault"
}

variable "acr_name" {
  type    = string
  default = "myACRregistry123"
}

variable "users" {
  type = list(object({
    name  = string
    role  = string # "developer" or "admin"
    email = string
  }))
  default = [
    {
      name  = "Amir"
      role  = "admin"
      email = "amir.modiri.master@gmail.com"
    },
    {
      name  = "Alice"
      role  = "developer"
      email = "alice@example.com"
    },
    {
      name  = "Charlie"
      role  = "developer"
      email = "charlie@example.com"
    }
  ]
}