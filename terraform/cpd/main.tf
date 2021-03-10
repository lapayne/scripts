# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create the resourcegroup and assign tags
resource "azurerm_resource_group" "cpdrg" {
  name     = var.azrg
  location = var.azregion

tags = {
        Environment = "Production"
        URL = "cpd.lap-it.com"
    }
}

#create the servicebus name space 
resource "azurerm_servicebus_namespace" "cpdqueue" {
  name                = var.aznamespacename
  location            = var.azregion
  resource_group_name = var.azrg
  sku                 = "Basic"
  depends_on = [azurerm_resource_group.cpdrg]
}

#create the queue used when CPD is completed
resource "azurerm_servicebus_queue" "completed" {
  name                = "completed"
  resource_group_name = var.azrg
  namespace_name      = var.aznamespacename
  depends_on = [azurerm_servicebus_namespace.cpdqueue]
}

#create the queue when you need to add new planned CPD
resource "azurerm_servicebus_queue" "planned" {
  name                = "planned"
  resource_group_name = var.azrg
  namespace_name      = var.aznamespacename
  depends_on = [azurerm_servicebus_namespace.cpdqueue]
}

#create the storage account used for storing data
resource "azurerm_storage_account" "cpdstorage" {
  name                     = var.azstorageaccountname
  resource_group_name      = var.azrg
  location                 = var.azregion
  account_tier             = "Standard"
  account_replication_type = "ZRS"
  account_kind = "StorageV2"
  min_tls_version = "TLS1_2"
  allow_blob_public_access = "true"
  depends_on = [azurerm_resource_group.cpdrg]
}

#used to hold image evidence of completed CPD (where appropriate)
resource "azurerm_storage_container" "cpdimages" {
  name                  = "evidence"
  storage_account_name  = var.azstorageaccountname
  container_access_type = "blob"
  depends_on = [azurerm_storage_account.cpdstorage]
}

resource "azurerm_storage_container" "dbbackup" {
  name                  = "dbbackup"
  storage_account_name  = var.azstorageaccountname
  container_access_type = "private"
  depends_on = [azurerm_storage_account.cpdstorage]
}

#add the app service we need to deploy to
resource "azurerm_app_service" "cpdappservice" {
  name                = "cpd"
  location            = var.azregion
  resource_group_name = var.azrg
  app_service_plan_id ="/subscriptions/3f6d29b1-08f7-4d8b-a298-8ea97dd77eda/resourceGroups/SharedService/providers/Microsoft.Web/serverfarms/wineapp-frontend"
  https_only = true
  site_config {
    linux_fx_version = "NODE|14-lts"
    app_command_line = "node app"
    use_32_bit_worker_process   = true 
    default_documents           = [
              "Default.htm",
              "Default.html",
              "Default.asp",
              "index.htm",
              "index.html",
              "iisstart.htm",
              "default.aspx",
              "index.php",
              "hostingstart.html",
    ]
  }
}

#add the UAT app service we need to deploy to
resource "azurerm_app_service" "cpduatappservice" {
  name                = "cpduat"
  location            = var.azregion
  resource_group_name = var.azrg
  app_service_plan_id ="/subscriptions/3f6d29b1-08f7-4d8b-a298-8ea97dd77eda/resourceGroups/SharedService/providers/Microsoft.Web/serverfarms/wineapp-frontend"
  https_only = true
  site_config {
    linux_fx_version = "NODE|14-lts"
    app_command_line = "node app"
    use_32_bit_worker_process   = true 
    default_documents           = [
              "Default.htm",
              "Default.html",
              "Default.asp",
              "index.htm",
              "index.html",
              "iisstart.htm",
              "default.aspx",
              "index.php",
              "hostingstart.html",
    ]
  }
}

#add in the adding of CPD records logic app
resource "azurerm_logic_app_workflow" "addCPDRcord" {
  name                = "addCPDRcord"
  location            = var.azregion
  resource_group_name = var.azrg
  depends_on = [azurerm_resource_group.cpdrg]
  workflow_schema = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
  workflow_version = "1.0.0.0" 
  parameters = {
    "$connections" = "",
  }
}

resource "azurerm_logic_app_workflow" "cpdaddplannedtoqueue" {
  name                = "cpdaddplannedtoqueue"
  location            = var.azregion
  resource_group_name = var.azrg
  depends_on = [azurerm_resource_group.cpdrg]
  workflow_schema = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
  workflow_version = "1.0.0.0" 
  parameters = {
    "$connections" = "",
  }
}

resource "azurerm_logic_app_workflow" "cpdplanned-dbstore" {
  name                = "cpdplanned-dbstore"
  location            = var.azregion
  resource_group_name = var.azrg
  depends_on = [azurerm_resource_group.cpdrg]
  workflow_schema = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
  workflow_version = "1.0.0.0" 
  parameters = {
    "$connections" = "",
  }
}

resource "azurerm_logic_app_workflow" "delCPD" {
  name                = "delCPD"
  location            = var.azregion
  resource_group_name = var.azrg
  depends_on = [azurerm_resource_group.cpdrg]
  workflow_schema = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
  workflow_version = "1.0.0.0" 
  parameters = {
    "$connections" = "",
  }
}

resource "azurerm_logic_app_workflow" "editCPD" {
  name                = "editCPD"
  location            = var.azregion
  resource_group_name = var.azrg
  depends_on = [azurerm_resource_group.cpdrg]
  workflow_schema = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
  workflow_version = "1.0.0.0" 
  parameters = {
    "$connections" = "",
  }
}

resource "azurerm_logic_app_workflow" "editplannedcpd" {
  name                = "editplannedcpd"
  location            = var.azregion
  resource_group_name = var.azrg
  depends_on = [azurerm_resource_group.cpdrg]
  workflow_schema = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
  workflow_version = "1.0.0.0" 

}

resource "azurerm_logic_app_workflow" "getCPDRecords" {
  name                = "getCPDRecords"
  location            = var.azregion
  resource_group_name = var.azrg
  depends_on = [azurerm_resource_group.cpdrg]
  workflow_schema = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
  workflow_version = "1.0.0.0" 
  parameters = {
    "$connections" = "",
  }
}

resource "azurerm_logic_app_workflow" "getPlannedCPD" {
  name                = "getPlannedCPD"
  location            = var.azregion
  resource_group_name = var.azrg
  depends_on = [azurerm_resource_group.cpdrg]
  workflow_schema = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
  workflow_version = "1.0.0.0" 
  parameters = {
    "$connections" = "",
  }
}

#application insights configuration
resource "azurerm_application_insights" "cpdappinsight" {
  name                = "cpd-appinsight"
  location            = var.azregion
  resource_group_name = var.azrg
  application_type    = "web"
  sampling_percentage = 0
}

resource "azurerm_cdn_profile" "cpdcdn" {
  name                = "cpdcdn"
  location            = "global"
  resource_group_name = var.azrg
  sku                 = "Standard_Microsoft"
}

resource "azurerm_cdn_endpoint" "cpdcdn" {
  name                = "cpdcdn"
  profile_name        = "cpdcdn"
  location            = var.azregion
  resource_group_name = var.azrg

     content_types_to_compress     = [
          "application/eot",
          "application/font",
          "application/font-sfnt",
          "application/javascript",
          "application/json",
          "application/opentype",
          "application/otf",
          "application/pkcs7-mime",
          "application/truetype",
          "application/ttf",
          "application/vnd.ms-fontobject",
          "application/x-font-opentype",
          "application/x-font-truetype",
          "application/x-font-ttf",
          "application/x-httpd-cgi",
          "application/x-javascript",
          "application/x-mpegurl",
          "application/x-opentype",
          "application/x-otf",
          "application/x-perl",
          "application/x-ttf",
          "application/xhtml+xml",
          "application/xml",
          "application/xml+rss",
          "font/eot",
          "font/opentype",
          "font/otf",
          "font/ttf",
          "image/svg+xml",
          "text/css",
          "text/csv",
          "text/html",
          "text/javascript",
          "text/js",
          "text/plain",
          "text/richtext",
          "text/tab-separated-values",
          "text/x-component",
          "text/x-java-source",
          "text/x-script",
          "text/xml",
        ]

      optimization_type             = "GeneralWebDelivery"
      origin_host_header            = "cpd.azurewebsites.net"

      querystring_caching_behaviour = "BypassCaching" 
      tags                          = {} 
        # (4 unchanged attributes hidden)

      delivery_rule {
          name  = "Nocacheroot"
          order = 1 

          cache_expiration_action {
              behavior = "BypassCache"
            }

          request_uri_condition {
              match_values     = [
                  "https://cpd.lap-it.com/",
                ] 
              negate_condition = false
              operator         = "Equal" 
              transforms       = [
                  "Lowercase",
                ] 
            }
        }
      delivery_rule {
          name  = "Nocacheplanned" 
          order = 2 

          cache_expiration_action {
              behavior = "BypassCache" 
            }

          request_uri_condition {
              match_values     = [
                  "https://cpd.lap-it.com/planned",
                ] 
              negate_condition = false 
              operator         = "Equal" 
              transforms       = [
                  "Lowercase",
                ] 
            }
        }

      origin {
          host_name  = "cpd.azurewebsites.net" 
          http_port  = 0 
          https_port = 0 
          name       = "cpd-azurewebsites-net" 
        }

      timeouts {}

}