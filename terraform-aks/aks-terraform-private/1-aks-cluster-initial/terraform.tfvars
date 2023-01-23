subscription = "<change here>"
location = "<change location>"
application = "AKS application"
environment = "DEV" //or PRDO or QA etc
aks-identity =  "id-aks-dev"
aks-resourcegroup = "aks-rg"
kubernetes_version = "1.25.4"
aks-network-rg = "aks-rg"
keyvault_name = "akskv-dev"
aks-vnet = "aks-vnet-dev"
aks-subnet-1 = "aks-subnet-pools-dev"
environment_full = "Development"
private_cluster = "true"
aks_name_prefix = "aks-cluster"
ssh_key_vault_secret = "ssh-key-pub" // public key stored in  a keyvault
private_dns_zone = "akszone.privatelink.northeurope.azmk8s.io" //private link for the private endpoint
aks_administrators = "AKS_Admins" // the admins group from active directory
public_autohorized_ranges= ["xx.xx.xx.xx/32"] // in case of non private cluster with restrictions


