
set-azcontext -subscription "cf19dafa"

$resourcegroupname = "test"
$name = "Webapptest2"
$location = "UK South"
$AppServicePlan = "Webapptest1sp"
New-AzWebApp -resourcegroupname $resourcegroupname -name $name -location $location -AppServicePlan $AppServicePlan