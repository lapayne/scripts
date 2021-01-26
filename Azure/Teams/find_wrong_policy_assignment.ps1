
$Wcl = new-object System.Net.WebClient
$Wcl.Headers.Add(“user-agent”, “PowerShell Script”)
$Wcl.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
 
Import-Module SkypeOnlineConnector
$Cred = Get-Credential
$CSSession = New-CsOnlineSession -Credential $Cred -overrideadmindomain "onmicrosoft.com"
Import-PSSession -Session $CSSession

$list = get-content .\list.txt
$wrong = 0
foreach($l in $list){


$callingpolicy = Get-CsOnlineUser -identity $l | select teamscallingpolicy



if($callingpolicy[0].teamscallingpolicy.trim() -ne "AllowCalling"){
  $wrong = 1
}

if($wrong -ne 0){
	write-host $l
	$wrong = 0
	}
}
if($meetingpolicy[0].teamsmeetingpolicy.trim() -ne "Allow Meetings"){
    $wrong = 1
   }
$meetingpolicy = Get-CsOnlineUser -identity $l | select teamsmeetingpolicy