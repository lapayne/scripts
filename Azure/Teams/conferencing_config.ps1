
try {
    Import-Module SkypeOnlineConnector
    $Cred = Get-Credential
    $CSSession = New-CsOnlineSession -Credential $cred -overrideadmindomain "onmicrosoft.com"
    Import-PSSession -Session $CSSession
     $users = get-content "h:\conference.txt"
    foreach($userId in $users){
    
        Grant-CsDialoutPolicy -identity $userId -policyname "DialoutCPCandPSTNDisabled"
        Set-CsOnlineDialInConferencingUser $userId –AllowTollFreeDialIn $false
    }
} 
catch {
     
     Write-Host "Failed for user " $userId
     
    }