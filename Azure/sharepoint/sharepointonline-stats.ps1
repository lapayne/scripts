$userName = "GL_SVC_M365_RO@global.cshare.net"
$Password = "01000000d08c9ddf0115d1118c7a00c04fc297eb010000001b09b572fc33a04d81c89f458f3d99fe0000000002000000000003660000c00000001000000016169452cb69fcc5ef235f29c7afb8340000000004800000a000000010000000964286aa742df4a29a4a5f1212f917f620000000d4dd078e68a76a38cda61037ab178167062e20fc46ab1b6acde0743db7054d8114000000f7d542b2d06b7a680dca008f5cd5c00124d19023"
$cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $userName, $(convertto-securestring $Password)

$url = 'https://computershare-admin.sharepoint.com'
Connect-SPOService -Url $url -credential $cred
#Enumerating all sites and calculating storage usage  
$sites = Get-SPOSite
$results = @()

foreach ($site in $sites) {
  $siteStorage = New-Object PSObject
  
  $percent = $site.StorageUsageCurrent / $site.StorageQuota * 100  
  $percentage = [math]::Round($percent,2)
	if($percentage -gt 90){
	  $siteStorage | Add-Member -MemberType NoteProperty -Name "Site Title" -Value $site.Title
	  $siteStorage | Add-Member -MemberType NoteProperty -Name "Site Url" -Value $site.Url
	  $siteStorage | Add-Member -MemberType NoteProperty -Name "Percentage Used" -Value $percentage
	  $siteStorage | Add-Member -MemberType NoteProperty -Name "Storage Used (MB)" -Value $site.StorageUsageCurrent
	  $siteStorage | Add-Member -MemberType NoteProperty -Name "Storage Quota (MB)" -Value $site.StorageQuota

	  $results += $siteStorage
  }
  $siteStorage = $null
}
$results | sort-object "percentage Used"

$smtpServer = "webmail.emea.cshare.net"
$smtpFrom = "M365Reports@computershare.com"
$smtpTo = "lee.payne@computershare.co.uk"
$messageSubject = "M365 high sharepoint usage"
$message = New-Object System.Net.Mail.MailMessage $smtpfrom, $smtpto
$message.Subject = $messageSubject

$message.Body = $results

$smtp = New-Object Net.Mail.SmtpClient($smtpServer)
$smtp.Send($message)