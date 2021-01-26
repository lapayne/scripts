$dnszone = "domain.com"
$dc = "domaincontroller.domain.com"
$searchstring = "*somestring*"

$dns = Get-DnsServerResourceRecord -zonename $dnszone -computername $dc
foreach($d in $dns){
	if($d.hostname.tostring() -like $searchstring){ 
		write-host $d.hostname
	}
}