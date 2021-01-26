Import-Module -Name MicrosoftTeams
$userName = "GL_SVC_M365_RO@global.cshare.net"
$Password = "01000000d08c9ddf0115d1118c7a00c04fc297eb010000001b09b572fc33a04d81c89f458f3d99fe0000000002000000000003660000c00000001000000016169452cb69fcc5ef235f29c7afb8340000000004800000a000000010000000964286aa742df4a29a4a5f1212f917f620000000d4dd078e68a76a38cda61037ab178167062e20fc46ab1b6acde0743db7054d8114000000f7d542b2d06b7a680dca008f5cd5c00124d19023"
$cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $userName, $(convertto-securestring $Password)
Connect-MicrosoftTeams -credential $cred

$teams = get-team
$emptyteams = @()

foreach($team in $teams){
	$tempobj = New-Object PSObject
	$members = ""
		if((Get-TeamUser -GroupId $team.GroupID| Where-Object {$_.Role -like "owner"}).count -eq 0){
        $tempobj | Add-Member -MemberType NoteProperty -Name "Site Title" -Value $team.displayname
        $tempobj | Add-Member -MemberType NoteProperty -Name "Team Members" -Value  (Get-TeamUser -GroupId $team.GroupID| Where-Object {$_.Role -like "member"}).count
		$emptyteams = $emptyteams + $tempobj
		}
		
		
}

$smtpServer = "mail"
$smtpFrom = "M365Reports"
$smtpTo = "email"
$messageSubject = "M365 Teams without owners"
$message = New-Object System.Net.Mail.MailMessage $smtpfrom, $smtpto
$message.Subject = $messageSubject
$message.IsBodyHTML = $true

$style = "<style>BODY{font-family: Arial; font-size: 10pt;}"
$style = $style + "TABLE{border: 1px solid black; border-collapse: collapse;}"
$style = $style + "TH{border: 1px solid black; background: #dddddd; padding: 5px; }"
$style = $style + "TD{border: 1px solid black; padding: 5px; }"
$style = $style + "</style>"

$message.Body = $emptyteams | ConvertTo-Html -Head $style

$smtp = New-Object Net.Mail.SmtpClient($smtpServer)
$smtp.Send($message)