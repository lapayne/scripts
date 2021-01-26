#sets up the URL for an individual queue
$url = "https://rabbitmq/api/queues/vhost/queuename"

#adds a user to access the Rabbit URI
$user = "rabbituser"
#converts a encrypted password into a secreure string for use in the requests
$key = [Byte[]] $key = (1..16)
$passwd = ConvertTo-SecureString -String "01000000d08c9ddf0115d1118c7a00c04fc297eb0100000051aae83e51f9d740826d683533c0e46d0000000002000000000003660000c0000000100000006b70bd027d065d469cea5585a0cec7b20000000004800000a000000010000000e1faad77ddcdca8fcf7aefe3b84bac5e300000009abb82d6fcdf20aa0d5671001da838be9e0a60ede0b305439750d9d0e8444587a514f788a0a7f4c409eb8b22489bf88314000000c874eb18dbd3238a73c3229fda1799034ccb3cbb"
$cred = New-Object System.Management.Automation.PSCredential ($user, $passwd)

#gets the queue details
$result = Invoke-RestMethod -uri $url -Credential $cred

#extracts attributes from the object and prints them
write-host "Messages in the queue:" $result.messages
write-host "Messages ready for delivery:" $result.messages_ready
write-host "Messages unacknowledged:" $result.messages_unacknowledged

#lets you grab detauls from each node individual
$nodeurl1 = "https://rabbitmq/api/nodes/rabbit@RMQM1"
$nodeurl2 = "https://rabbitmq/api/nodes/rabbit@RMQS1"

#shows if there is a memory or disk alert generated
$result = Invoke-RestMethod -uri $nodeurl1 -Credential $cred
write-host "Memory alarm" $result.mem_alarm
write-host "Disk alarm" $result.disk_free_alarm

#shows if there is a memory or disk alert generated
$result = Invoke-RestMethod -uri $nodeurl2 -Credential $cred
write-host "Memory alarm" $result.mem_alarm
write-host "Disk alarm" $result.disk_free_alarm

#gets the cluster details
$clusterurl = "https://rabbitmq.emea.cshare.net/api/overview"
$result = Invoke-RestMethod -uri $clusterurl -Credential $cred
write-host "Cluster total Messages " $result.queue_totals.messages
write-host "Cluster total Messages ready " $result.queue_totals.messages_ready
write-host "Cluster total Messages unacknowledged " $result.queue_totals.messages_unacknowledged
write-host "Cluster total Message publish rate " $result.message_stats.publish_details.rate
write-host "Cluster total Message delivery rate " $result.message_stats.deliver_get