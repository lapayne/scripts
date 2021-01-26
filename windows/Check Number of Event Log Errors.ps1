$info  = foreach ($log in "application", "system") {get-eventlog -LogName $log -EntryType error }
$groupedinfo = $info | group-object machinename, entrytype
$groupedinfo | select @{N="Computername";E={$_.name.split(',')[0]}},
                      @{N="EntryType";E={$_.name.split(',')[1]}},
                      count

