#Get RG
data "azurerm_resource_group" "Rg" {
  name = "kubRg"
}

resource "random_string" "randomName" {
  length  = 4
  lower   = true
  number  = true
  upper   = false
  special = false
}

#Create network and subnet (required by CNI plugin)
resource "azurerm_virtual_network" "vNetwork" {
  name                = "core-${random_string.randomName.result}"
  address_space       = ["10.1.0.0/16"]
  dns_servers         = ["1.1.1.1", "1.0.0.1"]
  resource_group_name = "${data.azurerm_resource_group.Rg.name}"
  location            = "${data.azurerm_resource_group.Rg.location}"
  tags                = "${data.azurerm_resource_group.Rg.tags}"

  subnet {
    name           = "kubSubnet-${random_string.randomName.result}"
    address_prefix = "10.1.0.0/24"
  }
}

#Create a container registry
resource "azurerm_storage_account" "storacc" {
  name                     = "stor${random_string.randomName.result}"
  resource_group_name      = "${data.azurerm_resource_group.Rg.name}"
  location                 = "${data.azurerm_resource_group.Rg.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = "${data.azurerm_resource_group.Rg.tags}"
}

resource "azurerm_container_registry" "cr" {
  name                = "cr${random_string.randomName.result}"
  resource_group_name = "${data.azurerm_resource_group.Rg.name}"
  location            = "${data.azurerm_resource_group.Rg.location}"
  admin_enabled       = true
  sku                 = "Classic"
  storage_account_id  = "${azurerm_storage_account.storacc.id}"
}

resource "azurerm_kubernetes_cluster" "k8sClu" {
  name                = "rlk8sclu-${random_string.randomName.result}"
  location            = "${data.azurerm_resource_group.Rg.location}"
  resource_group_name = "${data.azurerm_resource_group.Rg.name}"
  dns_prefix          = "${var.dnsPrefix}"

  agent_pool_profile {
    name            = "default"
    count           = 2
    vm_size         = "Standard_D1_v2"
    os_type         = "Linux"
    os_disk_size_gb = 30
    vnet_subnet_id  = "${lookup(azurerm_virtual_network.vNetwork.subnet[0], "id")}"
  }

  service_principal {
    client_id     = "${var.client_id}"
    client_secret = "${var.client_secret}"
  }

  network_profile {
    network_plugin = "azure"
  }

  role_based_access_control {
    enabled = true
  }

  tags = "${data.azurerm_resource_group.Rg.tags}"
}
