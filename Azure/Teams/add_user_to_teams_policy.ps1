
try {
    Import-Module SkypeOnlineConnector
    $Cred = Get-Credential
    $CSSession = New-CsOnlineSession -Credential $cred -overrideadmindomain "computershare.onmicrosoft.com"
    Import-PSSession -Session $CSSession
     
    foreach($userId in $users){
    Grant-CsTeamsCallingpolicy -identity $userId -policyname "AllowCalling"
    Grant-CsTeamsMeetingPolicy -identity $userId -policy "Allow Meetings"
    write-host $userID
}
    } catch {
     
     Write-Host "Exception: " $_.Exception.Message 
     
    }