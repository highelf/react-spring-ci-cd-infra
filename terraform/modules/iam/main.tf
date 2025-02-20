variable "aks_cluster_id" {
  type = string
}

variable "database_id" {
  type = string
}

resource "azurerm_role_assignment" "aks_deploy_access" {
  scope                = var.aks_cluster_id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}

resource "azurerm_role_assignment" "mysql_access" {
  scope                = var.database_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.db_identity.principal_id
}

resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = "aks-identity"
  location            = azurerm_resource_group.iam_rg.location
  resource_group_name = azurerm_resource_group.iam_rg.name
}

resource "azurerm_user_assigned_identity" "db_identity" {
  name                = "db-identity"
  location            = azurerm_resource_group.iam_rg.location
  resource_group_name = azurerm_resource_group.iam_rg.name
}

output "kubernetes_admin_group" {
  value = azurerm_role_assignment.aks_deploy_access.id
}

output "database_contributor_role" {
  value = azurerm_role_assignment.mysql_access.id
}
