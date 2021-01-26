# http://spuder.github.io/2016/automating-f5-powershell/ - List of sample cmdlets here 

Add-PSSnapin -name iControlSnapIn

#Initialize-F5.iControl -Hostname lanf5-Credentials (Get-Credential)

#Initialize-F5.iControl -Hostname dmzf5 -Credentials (Get-Credential) 

(Get-F5.iControl).ManagementPartition.get_partition_list() #gets partition list

(Get-F5.iControl).ManagementPartition.set_active_partition( (,"web") ) #sets partition to web


$poolNames = (Get-F5.iControl).LocalLBPool.get_list() # gets list of all pools in the partition
$nodeNames   = (Get-F5.iControl).LocalLBNodeAddressV2.get_list()
$nodeAddresses = (Get-F5.iControl).LocalLBNodeAddressV2.get_address($nodeNames)


####################################################################

############################################ Gets pools, members and ports 

$poolNames = (Get-F5.iControl).LocalLBPool.get_list() # gets list of all pools in the partition

foreach ($pool in $poolnames)
{
  #  Write-Host "pool is $pool"
    $members = (Get-F5.iControl).LocalLBPool.get_member_v2((,$pool))[0] # allows us to use .address for unknown reason
    ForEach ($m in $members ) { # for each member in pool member
    $nodeaddress = $m.address 
    $poolport = $m.port
    #"$pool $nodeaddress $poolport"  | Out-File -FilePath C:\Temp\abc.txt -Append # pool, pooladdress, poolport as one object each

    $filteredpool = $pool -replace '(.*)(-web|_web)(.*)', '$1'
    $filteredpool = $filteredpool -replace '/web/', 'http://'
    

    $csv = New-object psobject -property @{ # creates the CSV object 
     'Pool' = $filteredpool
     'NodeAddress' = $nodeaddress
     'Port' = $poolport
    }
       $csv | Export-Csv  "C:\Temp\poolsDMZ.csv" -append -NoTypeInformation # pool, pooladdress, poolport as one object each
    }
    
} 