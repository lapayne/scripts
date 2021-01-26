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
$output = "<?xml-stylesheet type=$([char]34)text/xsl$([char]34) href=$([char]34)F5_LC_Info.xsl$([char]34)?>"
$output | out-file -Append $outputfile
$output = "<device>"
$output | out-file -Append $outputfile

$wideips = $ic.GlobalLBWideIP.get_list()

foreach ($wideip in $wideips){
$output = ""
$output = $output + "<wideip><wideipname>"+$wideip+"</wideipname>"
$wideippool = $ic.GlobalLBWideIP.get_wideip_pool($wideip)[0][0].pool_name
$output = $output + "<vss>"
if($ic.GlobalLBPool.get_member_v2($wideippool)[0].length -ne 0){
	foreach($member in $ic.GlobalLBPool.get_member_v2($wideippool)[0]){
		$output = $output + "<vs><type>wideip</type><vsname>"+$member.name+"</vsname>"
		$vs = $member.name.tostring().trimstart("_Common_")
		$output = $output + "<vsip>"+$ic.LocalLBVirtualServer.get_destination_v2($vs)[0].address+"</vsip>"
		$output = $output + "<vsport>"+$ic.LocalLBVirtualServer.get_destination_v2($vs)[0].port+"</vsport>"
		$output = $output + "<vspool>"+$ic.LocalLBVirtualServer.get_default_pool_name($vs)+"</vspool>"
		$output = $output + "<poolmembers><poolmember><poolmembername>"+$ic.LocalLBPool.get_member($ic.LocalLBVirtualServer.get_default_pool_name($vs))[0][0].address+"</poolmembername>"
		$output = $output + "<poolmemberport>"+$ic.LocalLBPool.get_member($ic.LocalLBVirtualServer.get_default_pool_name($vs))[0][0].port+"</poolmemberport></poolmember></poolmembers>"
	


		$output = $output + "<irules>"
		$rules = $ic.LocalLBVirtualServer.get_rule($vs)
		$rules = $rules[0]

		if($rules.length -ne 0){
			foreach($rule in $rules){

				$output = $output + +$rule.rule_name+","
			}
		}
		else{$output = $output + "None"}
		$output = $output + "</irules></vs>"
	}
}
	else{$output = $output + "<vs><type>wideip</type><vsname>None</vsname><vsip>N/A</vsip><vsport>N/A</vsport><vspool>N/A</vspool><poolmembers><poolmember><poolmembername>N/A</poolmembername><poolmemberport>N/A</poolmemberport></poolmember></poolmembers><irules>None</irules></vs>"}

	$output = $output + "</vss>"
	
	
	
	$output = $output + "</wideip>"
	$output | out-file -Append $outputfile
}

$output = ""
$vslist = $ic.LocalLBVirtualServer.get_list()
foreach ($vs in $vslist){
	if( $ic.LocalLBVirtualServer.get_object_status($vs)[0].availability_status.tostring() -eq "AVAILABILITY_STATUS_GREEN"){
		$output = $output + "<wideip><wideipname>"+$vs+"</wideipname>"
		$output = $output +"<vss><type>vs</type>"
		$output = $output + "<vsname>"+$vs+"</vsname>"
		$output = $output + "<vs><vsip>"+$ic.LocalLBVirtualServer.get_destination_v2($vs)[0].address.tostring()+"</vsip>"
		$output = $output + "<vsport>"+$ic.LocalLBVirtualServer.get_destination_v2($vs)[0].port.tostring()+"</vsport>"
		
		if($ic.LocalLBVirtualServer.get_default_pool_name($vs)[0].tostring() -ne ""){
			$output = $output + "<vspool>"+$ic.LocalLBVirtualServer.get_default_pool_name($vs)[0].tostring()+"</vspool>"
		
			$output = $output + "<poolmembers>"
		
				$poolmembers = $ic.locallbpool.get_member_v2($ic.LocalLBVirtualServer.get_default_pool_name($vs))[0]
				$count=1
				foreach($member in $poolmembers){
					$memberstatus = $ic.LocalLBPool.get_member_object_status($ic.LocalLBVirtualServer.get_default_pool_name($vs), $member)
					$output = $output + "<poolmember><poolmembername>"+$member.address+"</poolmembername><poolmemberport>"+$member.port+"</poolmemberport></poolmember>"
				}
		
			$output = $output + "</poolmembers>"
		}
		else{$output = $output +"<vspool>None</vspool><poolmembers><poolmember><poolmembername>None</poolmembername><poolmemberport>0</poolmemberport></poolmember></poolmembers>"}
		$output = $output + "<irules>"
		$rules = $ic.LocalLBVirtualServer.get_rule($vs)
		$rules = $rules[0]
		if($rules.length -ne 0){
			foreach($rule in $rules){

				$output = $output +$rule.rule_name+", "
			}
		}
		else{$output = $output + "None"}
		$output = $output + "</irules></vs>"
	

		$output = $output + "</vss></wideip>"	
		$output | out-file -Append $outputfile
		$output = $null
		}
}
$output = $output + "</device>"
$output | out-file -Append $outputfile