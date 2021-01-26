Param(
  [Parameter(Mandatory=$true, position=0)][string]$csvfile
)

$ColumnHeader = "Server"

Write-Host "Reading file" $csvfile
$Servers = import-csv $csvfile | select-object $ColumnHeader

Write-Host "Started Pinging.."
foreach( $Server in $Servers) {
    if (test-connection $Server.("Server") -count 1 -quiet) {
       # write-host $Server.("Server") "Ping succeeded." -foreground green
        [System.Net.Dns]::GetHostByName($Server.("Server"))

    } else {
       #  write-host $Server.("Server") "Ping failed." -foreground red
        [System.Net.Dns]::GetHostByName($Server.("Server"))
    }
    
}

Write-Host "Pinging Completed."