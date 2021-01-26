try {
    Import-Module SkypeOnlineConnector
    $cred = Get-Credential
    $userId = read-host "Enter the users email address"
    
    $CSSession = New-CsOnlineSession -Credential $cred -overrideadmindomain "computershare.onmicrosoft.com"
    Import-PSSession -Session $CSSession

    Grant-CsTeamsCallingpolicy -identity $userId -policyname $null
    Grant-CsTeamsMeetingPolicy -identity $userId -policy $null          
    } catch {
     Write-Host "Exception: " $_.Exception.Message 
    }