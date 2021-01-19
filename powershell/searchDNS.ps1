################################################
# Searchs for all DNS entries on a             #
# MS AD integrated zone mtching a given string #
################################################

#define the zone you're looking at, a DC hosting it and the search string
$dnszone = "domain.com"
$dc = "domaincontroller.domain.com"
$searchstring = "*somestring*"

#gets all records in the zone
$dns = Get-DnsServerResourceRecord -zonename $dnszone -computername $dc

#loops through and writes out the ones matching the string
foreach($d in $dns){
	if($d.hostname.tostring() -like $searchstring){ 
		write-host $d.hostname
	}
}