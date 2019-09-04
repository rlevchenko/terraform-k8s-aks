provider "azurerm" {
  version         = "1.23.0"
  subscription_id = "99xxxx"
  tenant_id       = "d37xxxxx"
  client_secret   = "${var.client_secret}"
  client_id       = "360xxxxxxx"
}
