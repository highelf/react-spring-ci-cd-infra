variable "aks_cluster_id" {
  type = string
}

resource "azurerm_dashboard_grafana" "grafana" {
  name                = "azure-grafana"
  resource_group_name = azurerm_resource_group.monitoring_rg.name
  location            = azurerm_resource_group.monitoring_rg.location
  sku                 = "Standard"
}

resource "helm_release" "prometheus" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus"
  namespace        = "monitoring"
  create_namespace = true
}

resource "kubernetes_manifest" "cpu_alert" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "cpu-usage-alert"
      namespace = "monitoring"
    }
    spec = {
      groups = [{
        name = "cpu-alert-group"
        rules = [{
          alert = "HighCpuUsage"
          expr  = "100 * (1 - avg by(instance) (rate(node_cpu_seconds_total{mode=\"idle\"}[5m]))) > 80"
          for   = "2m"
          labels = {
            severity = "critical"
          }
          annotations = {
            summary     = "High CPU Usage detected"
            description = "CPU usage on node {{ $labels.instance }} has exceeded 80% for more than 2 minutes."
          }
        }]
      }]
    }
  }
}

resource "azurerm_grafana_alert_rule" "aks_alert" {
  name                 = "aks-high-cpu-alert"
  resource_group_name  = azurerm_resource_group.monitoring_rg.name
  grafana_dashboard_id = azurerm_dashboard_grafana.grafana.id
  condition = {
    query     = "100 * (1 - avg(rate(node_cpu_seconds_total{mode='idle'}[5m])))"
    operator  = "gt"
    threshold = 80
  }
  duration = "2m"
  severity = "Critical"
  message  = "High CPU usage detected in AKS"
}

resource "azurerm_grafana_alert_rule" "db_alert" {
  name                 = "db-high-cpu-alert"
  resource_group_name  = azurerm_resource_group.monitoring_rg.name
  grafana_dashboard_id = azurerm_dashboard_grafana.grafana.id
  condition = {
    query     = "100 * (1 - avg(rate(mysql_global_status_cpu_time{mode='idle'}[5m])))"
    operator  = "gt"
    threshold = 80
  }
  duration = "2m"
  severity = "Critical"
  message  = "High CPU usage detected in MySQL Database"
}

output "grafana_url" {
  value = azurerm_dashboard_grafana.grafana.endpoint
}
