Connect-AzAccount

$azstorageAccountName = ""
$azkey=""
$azuri=""

# The ComputerName, or host, is <storage-account>.file.core.windows.net for Azure Public Regions.
# $storageAccount.Context.FileEndpoint is used because non-Public Azure regions, such as sovereign clouds
# or Azure Stack deployments, will have different hosts for Azure file shares (and other storage resources).
Test-NetConnection -ComputerName ([System.Uri]::new($azstorageAccount.Context.FileEndPoint).Host) -Port 445


Invoke-Expression -Command "cmdkey /add:$azuri /user:$azstorageAccountName /pass:$azkey"
new-psdrive -Name Q -PSProvider Filesystem -Root "\\$azstorageAccountName\folder"