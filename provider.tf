provider "azurerm" {
  version         = "1.23.0"
  subscription_id = "fedxxxxx"
  tenant_id       = "e26xxxxx"
  client_secret   = "${var.client_secret}"
  client_id       = "5axxxxxx"
}
