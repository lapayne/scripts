#####################################################################################
# Author: Lee Payne																	#
# Last updated: 09/06/14															#
# version 1.0																		#
#####################################################################################

#########################################################
# Performs the base initialisation to the BIG-IP device #
#########################################################
function Do-Initialize()
{
	#Checks if the snapin has been loaded and if not loads it
	if ( (Get-PSSnapin | Where-Object { $_.Name -eq "iControlSnapIn"}) -eq $null )
	{
		Add-PSSnapIn iControlSnapIn
	}
	#Tries to log into the device with the supplied credentials
	$success = Initialize-F5.iControl -HostName $bigip -Username $uid -Password $pwd;

	#If an objects isnt returned representing the device it will log an error to the application event log
	if ( $success -eq $null )
	{ 
		Write-EventLog -Logname Application -Source CSHARE-F5 -EntryType Error -EventId 1 -Message "Failed to bind to F5 device: $bigip"
	}
	#If it did work it returns the objects representing the device
	return $success;
}
#checks if enough command line arguments have been supplied and if not prompts for the information
if ($args.Length -lt 4){
	#Reads in the device you want to check
	$bigip = Read-Host 'What device do you want to connect to?'
	#reads in your username
	$uid = Read-Host 'What is your username?'
	#reads in your password (doesnt display it on the command line)
	$pwd = Read-host 'What is your password?' -AsSecureString
	#Take the secure password and turn it into plain text to send to the F5 device
	$pwd = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pwd))
	#writes out to a file
	$outputfile = Read-Host "Enter the file name including full path"
}
else{

	#Reads in the device you want to check
	$bigip = $args[0]
	#reads in your username
	$uid = $args[1]
	#reads in your password (doesnt display it on the command line)
	$pwd = $args[2]
	#writes out to a file
	$outputfile = $args[3]


}
#Initialize the device
Do-Initialize

#Sets up a base control to use
$ic = get-f5.icontrol
$output = "<?xml version=$([char]34)1.0$([char]34)?>"
$output | out-file $outputfile
$output = "<?xml-stylesheet type=$([char]34)text/xsl$([char]34) href=$([char]34)F5_VIP_Info.xsl$([char]34)?>"
$output | out-file -Append $outputfile
$output = "<device>"
$output | out-file -Append $outputfile
foreach($par in  $ic.ManagementPartition.get_partition_list()) {
	$ic.ManagementPartition.set_active_partition($par.partition_name)
	foreach($vs in $ic.LocalLBVirtualServer.get_list()){
		#Grab a list of profiles assigned
		$profiles = $ic.LocalLBVirtualServer.get_profile($vs)
		#Take the first (and only) entry
		$profile = $profiles[0]
		
		#The VS Name
		$output = "<virtual_server><name>" +$vs.substring($vs.LastIndexOf("/")+1)+"</name>"
		#The VS IP address
		$vsip = $ic.LocalLBVirtualServer.get_destination_v2($vs)[0].address
		$output = $output + "<vip>" + $vsip.Substring($vsip.lastindexof("/")+1) + "</vip>"
		#The VS Port
		$output = $output +"<vip_port>" + $ic.LocalLBVirtualServer.get_destination_v2($vs)[0].port + "</vip_port>"
		#The VS Partition
		$output = $output +"<partition>" +  $par.partition_name+"</partition>"
		#The VS Availability
		
		switch ($ic.LocalLBVirtualServer.get_object_status($vs)[0].availability_status.tostring()){
		"AVAILABILITY_STATUS_GREEN"{$output = $output +"<state>Available</state>"}
		"AVAILABILITY_STATUS_BLUE"{$output = $output +"<state>Unknown</state>"}
		"AVAILABILITY_STATUS_RED"{$output = $output +"<state>Unavailable</state>"}
		default {$output = $output +"<state>Unknown</state>"}	
		}
		
		$desc = $ic.LocalLBVirtualServer.get_description($vs)[0].tostring()
		
		if($desc -ne ""){$output = $output + "<owner>"+$desc+"</owner>"}
		else{$output = $output + "<owner>no owner</owner>"}
		try{
		#The VS default pool description
		$pool = $ic.LocalLBVirtualServer.get_default_pool_name($vs)
		$pooldesc = $ic.LocalLBPool.get_description($pool)[0].tostring()
		if($pooldesc -ne ""){$output = $output + "<description>"+$pooldesc+"</description>"}
		else{$output = $output + "<description>No details</description>"}
		
		}
		catch{$output = $output+"<default_pool>" +"NO DEFAULT POOL"+"</default_pool>"}

		#The persistence profiles
		try{
			if($ic.LocalLBVirtualServer.get_persistence_profile($vs)[0][0].profile_name.tostring() -ne $null){
				$output = $output +"<default_persistance>" +   $ic.LocalLBVirtualServer.get_persistence_profile($vs)[0][0].profile_name+"</default_persistance>"
			}
		}
		catch{$output = $output + "<default_persistance>None</default_persistance>" }
		
		try{
			if($ic.LocalLBVirtualServer.get_fallback_persistence_profile($vs)[0][0].profile_name.tostring() -ne $null){
				$output = $output +"<fallback_persistance>" +   $ic.LocalLBVirtualServer.get_fallback_persistence_profile($vs)[0][0].profile_name+"</fallback_persistance>"
			}
		}
		catch{$output = $output + "<fallback_persistance>None</fallback_persistance>"}
		
		
		#The VLAN
		
		if($ic.LocalLBVirtualServer.get_vlan($vs)[0].state.tostring() -eq "STATE_DISABLED") {
			$output = $output +"<vlan>ALL</vlan>"
		}
		else{
			$output = $output +"<vlan>"+ $ic.LocalLBVirtualServer.get_vlan($vs)[0].vlans +"</vlan>"
		}
		#The VS protocol
		$output = $output +"<vs_protocol>" +  $ic.LocalLBVirtualServer.get_protocol($vs)[0].tostring().substring(9)+"</vs_protocol>"
		
		if($ic.LocalLBVirtualServer.get_protocol($vs)[0].tostring() -eq "PROTOCOL_TCP"){

			#The client protocol
			$result = $profile | ? {$_.profile_type.tostring() -eq "PROFILE_TYPE_TCP" -AND ($_.profile_context.tostring() -eq "PROFILE_CONTEXT_TYPE_CLIENT" -OR $_.profile_context -eq "PROFILE_CONTEXT_TYPE_ALL") }
			if($result -ne $null){
			$output = $output +"<vstype>Standard</vstype><client_profile>" +  $result.profile_name+"</client_profile>"
						
			#The server protocol
			$result = $profile | ? {$_.profile_type.tostring() -eq "PROFILE_TYPE_TCP" -AND ($_.profile_context.tostring() -eq "PROFILE_CONTEXT_TYPE_SERVER" -OR $_.profile_context -eq "PROFILE_CONTEXT_TYPE_ALL") }
			$output = $output +"<server_profile>" + $result.profile_name +"</server_profile>"
			}
			else {
			#The client protocol
			$result = $profile | ? {$_.profile_type.tostring() -eq "PROFILE_TYPE_FAST_L4" -AND ($_.profile_context.tostring() -eq "PROFILE_CONTEXT_TYPE_CLIENT" -OR $_.profile_context -eq "PROFILE_CONTEXT_TYPE_ALL") }
			$output = $output +"<vstype>Performance L4</vstype><client_profile>" +  $result.profile_name+"</client_profile>"
			
			#The server protocol
			$result = $profile | ? {$_.profile_type.tostring() -eq "PROFILE_TYPE_FAST_L4" -AND ($_.profile_context.tostring() -eq "PROFILE_CONTEXT_TYPE_SERVER" -OR $_.profile_context -eq "PROFILE_CONTEXT_TYPE_ALL") }
			$output = $output +"<server_profile>" + $result.profile_name +"</server_profile>"
			}
		
		}
		if($ic.LocalLBVirtualServer.get_protocol($vs)[0].tostring() -eq "PROTOCOL_UDP"){
			#The client protocol
			$result = $profile | ? {$_.profile_type.tostring() -eq "PROFILE_TYPE_UDP" -AND ($_.profile_context.tostring() -eq "PROFILE_CONTEXT_TYPE_CLIENT" -OR $_.profile_context -eq "PROFILE_CONTEXT_TYPE_ALL") }
			$output = $output +"<vstype>Standard</vstype><client_profile>" +  $result.profile_name+"</client_profile>"
			#The server protocol
			$result = $profile | ? {$_.profile_type.tostring() -eq "PROFILE_TYPE_UDP" -AND ($_.profile_context.tostring() -eq "PROFILE_CONTEXT_TYPE_SERVER" -OR $_.profile_context -eq "PROFILE_CONTEXT_TYPE_ALL") }
			$output = $output +"<server_profile>" + $result.profile_name +"</server_profile>"
		}
		else{
			#The client protocol
			$result = $profile | ? {$_.profile_type.tostring() -eq "PROFILE_TYPE_FAST_L4" -AND ($_.profile_context.tostring() -eq "PROFILE_CONTEXT_TYPE_CLIENT" -OR $_.profile_context -eq "PROFILE_CONTEXT_TYPE_ALL") }
			$output = $output +"<vstype>Performance L4</vstype><client_profile>" +  $result.profile_name+"</client_profile>"
			
			#The server protocol
			$result = $profile | ? {$_.profile_type.tostring() -eq "PROFILE_TYPE_FAST_L4" -AND ($_.profile_context.tostring() -eq "PROFILE_CONTEXT_TYPE_SERVER" -OR $_.profile_context -eq "PROFILE_CONTEXT_TYPE_ALL") }
			$output = $output +"<server_profile>" + $result.profile_name +"</server_profile>"
		
		}
			
		try{
			#The http profile
			$result = $profile | ? {$_.profile_type.tostring() -eq "PROFILE_TYPE_HTTP"}
			$output = $output +"<http_profile>" + $result.profile_name.tostring() +"</http_profile>"
		}
		catch{$output = $output +"<http_profile> None </http_profile>"}

		try{
			#The compression profile
			$result = $profile | ? {$_.profile_type.tostring() -eq "PROFILE_TYPE_HTTPCOMPRESSION"}
			$output = $output +"<compression_profile>" + $result.profile_name.tostring() +"</compression_profile>"
			}
			catch{$output = $output +"<compression_profile>None</compression_profile>"}
			
		try{
			#The acceleration profile
			$result = $profile | ? {$_.profile_type.tostring() -eq "PROFILE_TYPE_WEBACCELERATION"}
			$output = $output +"<acceleration_profile>" + $result.profile_name.tostring()+"</acceleration_profile>"
			}
			catch{$output = $output +"<acceleration_profile>None</acceleration_profile>"}
			
		try{
			#SSL CLient profile		
			$result = $profile | ? {$_.profile_type.tostring() -eq "PROFILE_TYPE_CLIENT_SSL"}
			$output = $output +"<client_ssl>" +  $result.profile_name.tostring()+"</client_ssl>"
		}
		catch{$output = $output +"<client_ssl>None</client_ssl>"}
		
		try{
			#SSL Server profile
			$result = $profile | ? {$_.profile_type.tostring() -eq "PROFILE_TYPE_SERVER_SSL"}
			$output = $output +"<server_ssl>" +  $result.profile_name.tostring()+"</server_ssl>"
		}
		catch{$output = $output +"<server_ssl>None</server_ssl>"}
		#SNAT pool
		if($ic.locallbvirtualserver.get_snat_pool($vs)[0].tostring() -ne ""){
			$output = $output +"<snat_pool>" +  $ic.locallbvirtualserver.get_snat_pool($vs)[0].tostring()+"</snat_pool>"
		}
		else{$output = $output +"<snat_pool>Automap</snat_pool>"}
		#Irules
		$output = $output + "<irules>"
		$rules = $ic.LocalLBVirtualServer.get_rule($vs)
		$rules = $rules[0]

		if($rules.length -ne 0){
			foreach($rule in $rules){

				$output = $output + "<irulename>"+$rule.rule_name+",</irulename>"
			}
		}
		else{$output = $output + "<irulename>None</irulename>"}
		$output = $output + "</irules><poolmembers>"
		
		if($ic.LocalLBVirtualServer.get_default_pool_name($vs) -ne "/web/all_vs" -AND $ic.LocalLBVirtualServer.get_default_pool_name($vs) -ne "/web/test-uk.computershare.net_web_0" -AND $ic.LocalLBVirtualServer.get_default_pool_name($vs) -ne  "/web/test-uk.emea.cshare.net_web_0"){
		
			$poolmembers = $ic.locallbpool.get_member_v2($ic.LocalLBVirtualServer.get_default_pool_name($vs))[0]
			$count=1
			foreach($member in $poolmembers){
			$memberstatus = $ic.LocalLBPool.get_member_object_status($ic.LocalLBVirtualServer.get_default_pool_name($vs), $member)
			$output = $output + "<poolmember><poolmembername>"+$member.address+"</poolmembername><poolmemberport>"+$member.port+"</poolmemberport>"
			
			switch($memberstatus[0][0].availability_status.tostring()){
			"AVAILABILITY_STATUS_RED" {$output = $output +"<poolmember_availability>Unavailable</poolmember_availability>"}
			"AVAILABILITY_STATUS_GREEN" {$output = $output +"<poolmember_availability>Available</poolmember_availability>"}
			"AVAILABILITY_STATUS_BLUE" {$output = $output +"<poolmember_availability>No health check</poolmember_availability>"}
			default {$output = $output +"<poolmember_availability>unknown</poolmember_availability>"}
			
			}
			switch ($memberstatus[0][0].enabled_status.tostring()){
			"ENABLED_STATUS_ENABLED" {$output = $output +"<poolmember_status>Enabled</poolmember_status>"}
			"ENABLED_STATUS_ENABLED" {$output = $output +"<poolmember_status>pool member disabled</poolmember_status>"}
			"ENABLED_STATUS_DISABLED_BY_PARENT" {$output = $output +"<poolmember_status>Node disabled</poolmember_status>"}
			default {$output = $output +"<poolmember_status>Unknown</poolmember_status>"}
			}
			
			
			
			$output = $output + "</poolmember>"
			$count = $count+1
			}
			$output = $output + "</poolmembers>"
		}
		else{
			$output = $output + "</poolmembers>"
		}
		$output = $output + "</virtual_server>"
		$output | out-file -Append $outputfile
	}
}
$output = $output + "</device>"
$output | out-file -Append $outputfile