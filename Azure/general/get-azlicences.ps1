import-module AzureAD
$userName = "GL_SVC_M365_RO"
$Password = "01000000d08c9ddf0115d1118c7a00c04fc297eb010000001b09b572fc33a04d81c89f458f3d99fe0000000002000000000003660000c00000001000000016169452cb69fcc5ef235f29c7afb8340000000004800000a000000010000000964286aa742df4a29a4a5f1212f917f620000000d4dd078e68a76a38cda61037ab178167062e20fc46ab1b6acde0743db7054d8114000000f7d542b2d06b7a680dca008f5cd5c00124d19023"
$cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $userName, $(convertto-securestring $Password)

Connect-AzureAD -credential $cred
$highusage = @()

$licences = Get-AzureADSubscribedSku | Select-object -Property Sku*,ConsumedUnits -ExpandProperty PrepaidUnits

foreach($l in $licences){
	$percent =  [math]::Round($l.consumedunits/$l.enabled*100,2)
    $remaining = $l.enabled - $l.consumedunits
	$name = "Unknown"
	
	switch($l.skupartnumber){
		STREAM{$name = "Microsoft Stream for O365 E3 SKU"}
		POWERAPPS_INDIVIDUAL_USER{$name = "Powerapps"}
		POWER_BI_PRO{$name = "Power BI for Office 365 Professional"}
		SPZA_IW{$name = "APP CONNECT IW"}
		WINDOWS_STORE{$name = "Microsoft Store"}
		ENTERPRISEPACK{$name = "OFFICE 365 E3"}
		PROJECTESSENTIALS{$name = "PROJECT ONLINE ESSENTIALS"}
		FLOW_FREE{$name = "Microsoft Flow Free Licence"}
		MICROSOFT_BUSINESS_CENTER{$name = "MICROSOFT BUSINESS CENTER"}
		OFFICE365_MULTIGEO{$name = "Office 365 Muti-geo licence"}
		MCOEV{$name = "Skype for Business Cloud PBX"}
		MCOPSTN1{$name = "SKYPE FOR BUSINESS PSTN DOMESTIC CALLING"}
		PROJECTPREMIUM{$name = "Project Online Premium"}
		CCIBOTS_PRIVPREV_VIRAL{$name = "Dynamics Bots Trial"}
		FORMS_PRO{$name = "Forms Pro Trial"}
		POWERAPPS_VIRAL{$name = "Microsoft PowerApps Plan 2 Trial"}
		POWER_BI_STANDARD{$name = "Power BI for Office 365 Standard"}
		EMS{$name = "Enterprise Mobility + Security E3"}
		MCOMEETADV{$name = "Skype for Business PSTN Conferencing"}
		RMSBASIC{$name = "Rights Management Basic"}
		PROJECTPROFESSIONAL{$name = "Project Online Professional"}
		MCOPSTN2{$name = "Skype for Business Pstn Domestic And International Calling"}
		TEAMS_COMMERCIAL_TRIAL{$name = "Microsoft Teams Commercial Cloud Trial"}
		RIGHTSMANAGEMENT_ADHOC{$name = "Azure Rights Management Services Ad-hoc"}
		}
	if ( $percent -gt 90){
		$myobj = New-Object -TypeName PSObject
		Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'SKU' -Value $name
		Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'percent' -Value $percent
		Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'Consumed' -Value $l.consumedunits
		Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'Total' -Value $l.enabled
        Add-Member -InputObject $myobj -MemberType 'NoteProperty' -Name 'Remaining' -Value $remaining
  
  $highusage += $myobj

	}

}
$smtpServer = "email"
$smtpFrom = "M365Reports"
$smtpTo = "lee.payne@email.com"
$messageSubject = "M365 high licence usage"
$message = New-Object System.Net.Mail.MailMessage $smtpfrom, $smtpto
$message.Subject = $messageSubject
$message.IsBodyHTML = $true

$style = "<style>BODY{font-family: Arial; font-size: 10pt;}"
$style = $style + "TABLE{border: 1px solid black; border-collapse: collapse;}"
$style = $style + "TH{border: 1px solid black; background: #dddddd; padding: 5px; }"
$style = $style + "TD{border: 1px solid black; padding: 5px; }"
$style = $style + "</style>"

$message.Body = $highusage | ConvertTo-Html -Head $style



$smtp = New-Object Net.Mail.SmtpClient($smtpServer)
$smtp.Send($message)

