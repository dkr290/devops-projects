##the terraform.tfvars fole should looke like this 

subscription = "some ID for subscription"
location = "North Europe"
application = "AKS"
technical_owner = "Some Owner"
environment = "DEV"
aks-identity =  "aks-id-dev"
aks-resourcegroup = "aks-rg-dev"
kubernetes_version = "1.23.8"
keyvault_name = "aks-kv-dev"
aks-vnet = "aks-vnet"
aks-subnet-1 = "aks-nodepools-subnet"
private_cluster = "false"
aks_name_prefix = "aks-cluster"
private_dns_zone = "aksdev.privatelink.northeurope.azmk8s.io"
aks_administrators = "k8sadmins"
public_autohorized_ranges = ["x.x.x.x/32"]