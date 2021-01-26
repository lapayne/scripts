#added line for testing
Import-Module -name AzureAD
Import-Module -Name MicrosoftTeams

#Login to AzureAD & Microsoft Teams
$cred = Get-Credential
Connect-AzureAD -Credential $cred
Connect-MicrosoftTeams -Credential $cred

#Import CSV file of users
$csv = Import-Csv -Path C:\temp\callingonly.csv
$full = Get-Content -Path c:\temp\callsandmeeting.txt

#Assign members calling policies only

New-CsBatchPolicyAssignmentOperation -OperationName "AssignCallingPolicy" -PolicyType TeamsCallingPolicy -PolicyName "AllowCalling" -Identity $csv.userprincipalname

#Assign members meeting and calling policies

New-CsBatchPolicyAssignmentOperation -OperationName "AssignMeetingPolicy" -PolicyType TeamsMeetingPolicy -PolicyName "Allow Meetings" -Identity $full
New-CsBatchPolicyAssignmentOperation -OperationName "AssignCallingPolicy" -PolicyType TeamsCallingPolicy -PolicyName "AllowCalling" -Identity $full

#Check progress of Bulk Assignment Operation

$operation = Get-CsBatchPolicyAssignmentOperation | Out-GridView -PassThru
Get-CsBatchPolicyAssignmentOperation -Identity $operation.OperationId | select-object -ExpandProperty UserState | export-csv c:\temp\failedusers.csv
