variable "loc" {
  description = "Default Azure Region"
  default     = "westeurope"
}

variable "tags" {
  default = {
    dept = "IT"
    env  = "dev"
  }
}

variable "dnsPrefix" {
  default = "rlev"
}

variable "client_id" {
  default = "5a3xxxxxx"
}

variable "client_secret" {}
