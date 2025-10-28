terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0" 
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.7"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true 
}

# Helper for unique ACR name
resource "random_id" "id" {
  byte_length = 8
}

# 1. Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "devops-project-rg-eastus2" 
  location = "East US 2" # New location to bypass API version conflict
}

# 2. Azure Container Registry (ACR)
resource "azurerm_container_registry" "acr" {
  name                = "myprojectacr${random_id.id.hex}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true 
}

# 3. Azure Kubernetes Service (AKS)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "devops-project-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "devopsprojectaks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }
  
  # REMOVED: kubernetes_version = "1.27" - This was causing the K8sVersionNotSupported error

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control_enabled = true
}

# Give the AKS cluster (via its identity) the 'AcrPull' role on the ACR
resource "azurerm_role_assignment" "aks_to_acr" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id 
}