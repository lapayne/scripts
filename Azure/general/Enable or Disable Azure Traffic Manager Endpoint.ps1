
#This is a simple script to change the traffic manager endpoints for CPM2 deployments

#Define the list of paramaters
param (
    [string] $EndpointToEnable = "site unavailable",
    [string] $FirstEndpointToDisable = "eastasia",
    [String] $SecondEndpointToDisable = "eastasia2",
    [string] $ProfileName1 = "plans",
    [string] $ProfileName2 = "identity",
    [string] $ResourceGroupName = "rg1",
    [String] $SubscriptionID = "28741919"
)

#Set the context to the correct Azure Subscription
#set-azcontext -subscription $SubscriptionID

#Enable the "Site Unavailable" Endpoint, this puts the sites into maintenance mode
Enable-AzureRMTrafficManagerEndpoint -Name $EndpointToEnable -Type AzureEndpoints -ProfileName $ProfileName1 -ResourceGroupName $ResourceGroupName 
Enable-AzureRMTrafficManagerEndpoint -Name $EndpointToEnable -Type AzureEndpoints -ProfileName $ProfileName2 -ResourceGroupName $ResourceGroupName

#Disable the other endpoints, so that all traffic goes to the maintenance page endpoint
Disable-AzureRMTrafficManagerEndpoint -Name $FirstEndpointToDisable -Type AzureEndpoints -ProfileName $ProfileName1 -ResourceGroupName $ResourceGroupName -Force
Disable-AzureRMTrafficManagerEndpoint -Name $SecondEndpointToDisable -Type AzureEndpoints -ProfileName $ProfileName2 -ResourceGroupName $ResourceGroupName -Force

