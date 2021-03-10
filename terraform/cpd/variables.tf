variable "azregion" {
    description = "The region that this will reside in"
    type    = string
    default = "uksouth"
}

variable "azrg" {
    description = "The resource group you want to use"
    type    = string
    default = "cpd"
}

variable "aznamespacename" {
    description = "The name of your queue namespace"
    type    = string
    default = "cpdqueue"
}

variable "azstorageaccountname" {
    description = "The name of your storage account"
    type    = string
    default = "cpdstorageaccount"
}

variable "azapimgmtname" {
    description = "The name of your API Management account"
    type    = string
    default = "CPDAPIMgmt"
}