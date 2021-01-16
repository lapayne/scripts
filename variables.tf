variable "location" {}

variable "prefix" {
  type    = string
  default = "lp"
}

variable "tags" {
  type = map

  default = {
    Environment = "Production"
    Dept        = "Devops"
    URL         = "www.lap-it.com"
  }
}

variable "sku" {
  default = {
    uksouth = "18.04-LTS"
    ukwest  = "18.04-LTS"
  }
}


