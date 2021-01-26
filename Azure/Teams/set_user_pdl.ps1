<#
Valid attribute values are:
EUR = Europe and South Africa
GBR = Great Britain and Channel Islands
NAM = NA region
APC = Asia Pacific (outside AU)
AUS = Australia
#>
import-module ActiveDirectory
#sets the region and server variables to empty so they can be evaluated
$region = ""
$server = ""

#grab the persons UPN fromt he command line
$user = read-host -prompt "Enter the username in UPN (user@domain) format: "

#determine the region based on the bit after the @
switch ($user.split("@")[1].tolower().trim() ) {

    #Get input for GBR or European user and set the variables
    "emea.cshare.net" {
        do{
            $region = read-host -prompt "This should be GBR (UK, Ireland and CI) or EUR (The rest of Europe and South Africa)?" 
            $server = "ldap"
            write-host $region
        }
        until($region -eq "GBR" -or $region -eq "EUR")
    }
    #Set all american users to the correct values
    "america.cshare.net" {
        $region = "NAM"
        $server = "ldap"
    }
    #Get input for AUS or Asia Pac user and set the variables
    "oceania.cshare.net" {
        do{
            $region = read-host -prompt "Should this be AUS (within Australia) or APC (the rest of OCEANIA region?"
            $server = "ldap"
        }
        until($region -ne "AUS" -or $region -ne "APC")
    }
}
#run the command to set the Active Directory attribute
get-aduser -filter {UserPrincipalName -eq $user} -server $server | set-aduser $_ -server $server -replace @{extensionAttribute5=$region}