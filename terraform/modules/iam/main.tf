variable "aks_cluster_id" {
  type = string
}

variable "database_id" {
  type = string
}

variable "users" {
  type = list(object({
    name  = string
    role  = string # "developer" or "admin"
    email = string
  }))
}

resource "azurerm_role_assignment" "aks_deploy_access" {
  count               = length(var.users)
  scope                = var.aks_cluster_id
  role_definition_name = var.users[count.index].role == "admin" ? "Azure Kubernetes Service RBAC Cluster Admin" : "Azure Kubernetes Service RBAC Writer"
  principal_id         = azurerm_user_assigned_identity.aks_identity[count.index].principal_id
}

resource "azurerm_role_assignment" "mysql_access" {
  scope                = var.database_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.db_identity.principal_id
}

resource "azurerm_user_assigned_identity" "aks_identity" {
  count               = length(var.users)
  name                = "aks-identity-${var.users[count.index].name}"
  location            = azurerm_resource_group.iam_rg.location
  resource_group_name = azurerm_resource_group.iam_rg.name
}

resource "azurerm_user_assigned_identity" "db_identity" {
  name                = "db-identity"
  location            = azurerm_resource_group.iam_rg.location
  resource_group_name = azurerm_resource_group.iam_rg.name
}

output "kubernetes_admin_group" {
  value = azurerm_role_assignment.aks_deploy_access[*].id
}

output "database_contributor_role" {
  value = azurerm_role_assignment.mysql_access.id
}

output "user_credentials" {
  value = [for user in var.users : "User ${user.name} with role ${user.role} has been granted access. Credentials will be sent to ${user.email}."]
}
