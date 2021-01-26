$DMZCSVLocation = "DMZ.txt"
$LANCSVLocation = "LAN.txt"
$OutputLocation = "LANLookup.txt"

$servers = get-content $LANCSVLocation

foreach ($i in $servers)
{

try
    {
    $ip = [System.Net.Dns]::GetHostbyaddress("$i")
    $ConsolidatedDNSandIP = $ip.hostname + ",$i"
    $ConsolidatedDNSandIP | out-file -Append $OutputLocation
    }

catch
    {
    $errorMessage = "Null DNS" + ",$i" 
    $errorMessage | out-file -Append $OutputLocation
    }

}