variable "environment" {
  type = string
}

variable "mysql_sku" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "resource_group_location" {
  type = string
}

variable "administrator_login" {
  type = string
  default = "adminuser"
}

variable "administrator_password" {
  type = string
  default = "P@ssword1234"
}

variable "server_edition" {
  type = string
  default = "GeneralPurpose"
}

variable "vcores" {
  type = number
  default = 4
}

variable "storage_size_gb" {
  type = number
  default = 100
}

variable "mysql_version" {
  type = string
  default = "5.7"
}


variable "dbname" {
  type = string
  default = "payroll"
}


variable "storage_iops" {
  type = number
  default = 360
}

variable "storage_autogrow" {
  type = string
  default = "Enabled"
}

resource "random_string" "mysql_suffix" {
  length  = 8
  special = false
  upper = false
}

resource "azurerm_mysql_flexible_server" "mysql" {
  name                = "mysql-${var.environment}-${random_string.mysql_suffix.result}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  sku_name            = var.mysql_sku
  administrator_login = var.administrator_login
  administrator_password = var.administrator_password
  version             = var.mysql_version

  storage {
    size_gb            = var.storage_size_gb
    iops               = var.storage_iops
    auto_grow_enabled  = var.environment == "prod" ? var.storage_autogrow == "Enabled" : false
  }

}

resource "azurerm_mysql_flexible_database" "database" {
  name                = var.dbname
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

output "mysql_server_name" {
  value = azurerm_mysql_flexible_server.mysql.name
}

output "mysql_database_name" {
  value = azurerm_mysql_flexible_database.database.name
}
