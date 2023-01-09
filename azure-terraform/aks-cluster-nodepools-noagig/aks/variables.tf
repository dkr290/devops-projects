variable "location" {}
variable "resource_group_name" {}
variable "aks_name" {}
variable "aks_dns_prefix" {}
variable "aks_kubernetes_version" {}
variable "aks_node_resource_group" {}
variable "aks_private_cluster"        {}
variable "aks_default_pool_size"  {}
variable "autoscaling_max_count" {}
variable "autoscaling_min_count" {}
variable "aks_os_disk_size_gb" {}
variable "aks_node_labels" {}
variable "aks_tags"       {}
variable "aks_user_assigned_identity" {}
variable "aks_log_analytics_workspace" {}
variable "aks_role_based_access_control" {}
variable "aks_rbac_ad_group_admin" {}
variable "aks-key" {
    default = "aks-key.pub"
}
variable "aks_vnet_subnet_id" {}
variable "aks_public_authorized_ranges" {}

variable "aks_aksrole_zone_principal_id" {}
variable "aks_azure_keyvault_secrets_provider" {}
variable "aks_node_pools" {}
variable "aks_private_dns_zone" {}
variable "aks_agic_id" {
    default = "123"
} 


