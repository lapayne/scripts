#####################################################################################
# Secret Santa powershell                                                           #
# Has a list of participants which is then gone thorugh to match them up randomly   #
# They are then emailed their giftee                                                #
#####################################################################################

#import the Active directory module
Get-Module -ListAvailable ActiveDirectory

#define the list of participants then clone it to a secondary list for givers
[System.Collections.ArrayList]$recievers = "user1", "user2", "user3", "user4"
[System.Collections.ArrayList]$senders = $recievers.clone()

#if you'd prefer to grab an AD group then use the following line (changing the group as required)
#[System.Collections.ArrayList]$recievers = get-adgroupmember "domain group" | select -expandproperty samaccountname  

#Set the default subject and the current year
$subject = "Welcome to Secret Santa "+ (get-date).year

#loop through each sender one at a time to determine their partner
foreach($s in $senders){

    do{
        #get a random reciever for the gifter
        $r = $recievers[(get-random -minimum 0 -maximum $recievers.count)]
        #keep doing it until the gifter is not the giftee
    } until ($s -ne $r)
        #grab the givenname from the active directory and then create the email body
        $body = "Hi "+(get-aduser $s -properties givenname | select-object  -expandproperty givenname)+ ",`nThis year your secret santa is  "+ (get-aduser $r -properties displayName,mail | select-object -expandproperty displayName) +"  please have fun while getting their gift and a reminder that the price limit is 10 of your finest English (or Scottish) pounds"
        
        #remove the reciever so they only get one gift
        $recievers.Remove($r)

        #send the email message to the giftee with the details in
        Send-MailMessage -to (get-aduser $s -properties mail | select-object  -expandproperty mail) -subject $subject -body  $body -smtpserver mail.emea.cshare.net -from "secretsanta@mydomain.com"

}


