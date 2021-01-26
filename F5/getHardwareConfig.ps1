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
	$bigips = Read-Host 'What device do you want to connect to? (you can enter a comma seperated list)'
	$bigips = $bigips.split(",")
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
	$bigips = $args[0]
	$bigips = $bigips.split(",")
	#reads in your username
	$uid = $args[1]
	#reads in your password (doesnt display it on the command line)
	$pwd = $args[2]
	#writes out to a file
	$outputfile = $args[3]
}
$output = "<?xml version=$([char]34)1.0$([char]34)?>"
$output | out-file $outputfile
$output = "<?xml-stylesheet type=$([char]34)text/xsl$([char]34) href=$([char]34)F5_Device_Info.xsl$([char]34)?>"
$output | out-file -Append $outputfile
$output = "<configurations>"
$output | out-file -Append $outputfile

foreach($bigip in $bigips){

#Initialize the device
Do-Initialize

#Sets up a base control to use
$ic = get-f5.icontrol

#setup the device for each item
$output = "<device>"
$output | out-file -Append $outputfile

$devicename = $ic.ManagementDevice.get_local_device().tostring()
#Gather hardware configuration data
$output = "<devicename>"+$devicename.substring(8)+"</devicename>"

if(!($bigip -As [IPAddress] -As [Bool])){
	$bigip = [System.Net.Dns]::GetHostAddresses($bigip)[0].ipaddresstostring

}

switch -wildcard ($bigip)
{
	"172.27*" {$output = $output + "<region>EMEA</region>"} 
	"172.28*" {$output = $output + "<region>AU</region>"}
	default {$output = $output + "<region>NA</region>"}
}

$licensed = $ic.ManagementDevice.get_active_modules($devicename)[0]
$output = $output + "<licensedfeatures>"

switch -wildcard ($licensed)
{
	"*LTM*"{$output = $output + "LTM "}
	"*ASM*"{$output = $output + "ASM "}
	"*APM*"{$output = $output + "APM "}
	"*GTM*"{$output = $output + "GTM "}
	"*AFM*"{$output = $output + "AFM "}
	"*Link Controller*"{$output = $output + "LC "}

}
$output = $output + "</licensedfeatures>"

$output = $output + "<platform>"+$ic.ManagementDevice.get_marketing_name($devicename)+"</platform>"
$output = $output + "<swver>"+$ic.ManagementDevice.get_software_version($devicename)+ " " +$ic.ManagementDevice.get_edition($devicename)+"</swver>"

if($ic.NetworkingTrunk.get_list()){	$output = $output + "<trunk>yes</trunk>"}
else{$output = $output + "<trunk>no</trunk>"}


$output | out-file -Append $outputfile

$output = "</device>"
$output | out-file -Append $outputfile

}

$output = "</configurations>"
$output | out-file -Append $outputfile