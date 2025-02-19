resource "azurerm_resource_group" "network_rg" {
  name     = "network-rg-${var.environment}"
  location = var.location
}

module "network" {
  source              = "./modules/network"
  environment         = var.environment
  subnet_cidr         = var.subnet_cidr
  vnet_cidr           = var.vnet_cidr
  resource_group_name = azurerm_resource_group.network_rg.name
  location            = azurerm_resource_group.network_rg.location
}

resource "azurerm_resource_group" "aks_rg" {
  name     = "aks-rg-dev"
  location = var.location
}

module "aks" {
  source  = "./modules/aks"
  environment = var.environment
  vm_size = var.aks_vm_size[var.environment]
  node_count = var.aks_node_count[var.environment]
  vnet_id     = module.network.vnet_id
  subnet_id   = module.network.subnet_id
  service_cidr = var.aks_service_cidr
  dns_service_ip = var.aks_dns_service_ip
  resource_group_name     = azurerm_resource_group.aks_rg.name
  resource_group_location = azurerm_resource_group.aks_rg.location
  acr_name = var.acr_name
  location = var.location
  key_vault_name =  var.key_vault_name
    depends_on = [module.network]
}

resource "azurerm_resource_group" "mysql_rg" {
  name     = "mysql-rg-dev"
  location = var.location
}

module "mysql" {
  source  = "./modules/mysql"
  mysql_sku = var.mysql_sku[var.environment]
  environment = var.environment
  resource_group_name     = azurerm_resource_group.mysql_rg.name
  resource_group_location = azurerm_resource_group.mysql_rg.location
  depends_on = [module.aks]
}

# module "iam" {
#   source  = "./modules/iam"
#   aks_cluster_id = module.aks.aks_cluster_id
#   database_id    = module.mysql.database_id
#   users          = var.iam_users[var.environment]
#   depends_on = [module.aks]
# }

# module "monitoring" {
#   source  = "./modules/monitoring"
#   aks_cluster_id = module.aks.aks_cluster_id
#   depends_on = [module.aks, module.mysql]
# }

