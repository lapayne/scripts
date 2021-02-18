function Get-GraphApiAccessToken {
       [CmdletBinding()]
    [OutputType([String])]
    param (
        [Parameter(HelpMessage="Enter the application ID and client secret as a PSCredential object")]
        [PSCredential]
        $Credential,

        [Parameter(Mandatory, HelpMessage = "Enter the Tenant Id GUID")]
        [string]
        $TenantId
    )

    [string]$appId = $null
    [string]$appSecret = $null

    if (-not ($PSBoundParameters.ContainsKey('Credential'))) {
        $Credential = Get-Credential -Message "User name = Application/Client ID | Password = Client Secret"
    }

    if ($Credential) {
        $appId = $Credential.UserName
        $appSecret = $Credential.GetNetworkCredential().Password

        $oauthUri = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"

        $tokenBody = @{
            client_id     = $appId
            client_secret = $appSecret
            scope         = "https://graph.microsoft.com/.default"    
            grant_type    = "client_credentials"
        }

        $tokenRequestResponse = Invoke-RestMethod -Uri $oauthUri -Method POST -ContentType "application/x-www-form-urlencoded" -Body $tokenBody -UseBasicParsing
        ($tokenRequestResponse).access_token
    }
    else {
        Write-Warning -Message "No credentials found, exiting command."
    }
}

function Get-TeamsPstnCalls {
     [CmdletBinding()]
    param (
        [Parameter(
            Mandatory,
            ParameterSetName="DateRange",
            HelpMessage="Start date to search for call records in YYYY-MM-DD format"
        )]
        [string]
        $StartDate,

        [Parameter(
            Mandatory,
            ParameterSetName="DateRange",
            HelpMessage="End date to search for call records in YYYY-MM-DD format"
        )]
        [string]
        $EndDate,

        [Parameter(
            Mandatory,
           ParameterSetName="NumberDays",
            HelpMessage="The number of days previous to today to search for call records"
        )]
        [ValidateRange(1,90)]
        [int]
        $Days,

        [Parameter(Mandatory, HelpMessage="Access token string for authorization to make Graph API calls")]
        [string]
        $AccessToken
    )

    $headers = @{
        "Authorization" = $AccessToken
    }

    if ($PSCmdlet.ParameterSetName -eq "DateRange") {
        $requestUri = "https://graph.microsoft.com/beta/communications/callRecords/getPstnCalls(fromDateTime=$StartDate,toDateTime=$EndDate)"
    }
    elseif ($PSCmdlet.ParameterSetName -eq "NumberDays") {
        $today = [datetime]::Today
        $toDateTime = $today.AddDays(1)
        $toDateTimeString = Get-Date -Date $toDateTime -Format yyyy-MM-dd
        $fromDateTime = $today.AddDays(-($Days - 1))
        $fromDateTimeString = Get-Date -Date $fromDateTime -Format yyyy-MM-dd

        $requestUri = "https://graph.microsoft.com/beta/communications/callRecords/getPstnCalls(fromDateTime=$fromDateTimeString,toDateTime=$toDateTimeString)"
    }
    
    
    while (-not ([string]::IsNullOrEmpty($requestUri))) {
        try {
            $requestResponse = Invoke-RestMethod -Method GET -Uri $requestUri -Headers $headers -ErrorAction STOP
        }
        catch {
            $_
        }

        $requestResponse.value

        if ($requestResponse.'@odata.NextLink') {
            $requestUri = $requestResponse.'@odata.NextLink'
        }
        else {
            $requestUri = $null
        }
    }
}

function Get-TeamsDirectRoutingCalls {
     [CmdletBinding()]
    param (
        [Parameter(
            Mandatory,
            ParameterSetName="DateRange",
            HelpMessage="Start date to search for call records in YYYY-MM-DD format"
        )]
        [string]
        $StartDate,

        [Parameter(
            Mandatory,
            ParameterSetName="DateRange",
            HelpMessage="End date to search for call records in YYYY-MM-DD format"
        )]
        [string]
        $EndDate,

        [Parameter(
            Mandatory,
            ParameterSetName="NumberDays",
            HelpMessage="The number of days previous to today to search for call records"
        )]
        [ValidateRange(1,90)]
        [int]
        $Days,

        [Parameter(Mandatory, HelpMessage="Access token string for authorization to make Graph API calls")]
        [string]
        $AccessToken
    )

    $headers = @{
        "Authorization" = $AccessToken
    }

    if ($PSCmdlet.ParameterSetName -eq "DateRange") {
        $requestUri = "https://graph.microsoft.com/beta/communications/callRecords/getDirectRoutingCalls(fromDateTime=$StartDate,toDateTime=$EndDate)"
    }
    elseif ($PSCmdlet.ParameterSetName -eq "NumberDays") {
        $today = [datetime]::Today
        $toDateTime = $today.AddDays(1)
        $toDateTimeString = Get-Date -Date $toDateTime -Format yyyy-MM-dd
        $fromDateTime = $today.AddDays(-($Days - 1))
        $fromDateTimeString = Get-Date -Date $fromDateTime -Format yyyy-MM-dd

        $requestUri = "https://graph.microsoft.com/beta/communications/callRecords/getDirectRoutingCalls(fromDateTime=$fromDateTimeString,toDateTime=$toDateTimeString)"
    }

    while (-not ([string]::IsNullOrEmpty($requestUri))) {
        try {
            $requestResponse = Invoke-RestMethod -Method GET -Uri $requestUri -Headers $headers -ErrorAction STOP
        }
        catch {
            $_
        }

        $requestResponse.value

        if ($requestResponse.'@odata.NextLink') {
            $requestUri = $requestResponse.'@odata.NextLink'
        }
        else {
            $requestUri = $null
        }
    }
}

$securestring = convertto-securestring "secretvalue" -asplaintext -force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist "applicationID", $securestring
$token = get-graphapiaccesstoken -credential $cred -tenantID "tenantid"
$enddate = get-date -format "yyyy-MM-dd"
$startdate =  (get-date).addmonths(-2).tostring("yyyy-MM-dd")
$records = Get-TeamsPstnCalls -startdate $startdate -enddate $enddate -accesstoken $token
[System.Collections.ArrayList]$notfound = @()


$name = $records | select-object userprincipalname | sort-object UserPrincipalName | get-unique -asstring

$groupusers = Get-ADGroup -server domaincontroller "conferencing_user_group_name" -properties members

foreach($groupmember in $groupusers.members){

                $u = (get-aduser $groupmember -server domaincontroller:3268).userPrincipalName.tolower()
                if(!$name.userPrincipalName.tolower().contains($u)){
                                $notfound.Add($u)
                }
}
write-host $notfound