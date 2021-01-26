

$computername = Get-Content env:COMPUTERNAME 

.\SumoCollector_windows-x64_19_253-26.exe -console -q `
"-Vsumo.accessid=idkey" `
"-Vsumo.accesskey=accesskey" `
"-Vcollector.name=$computername" `
"-Vproxy.host=proxy" `
"-Vproxy.port=8080" `
"-Vproxy.user=sumouser" `
"-Vproxy.password=sumopass" `
"-VsyncSources=E:\\SumoSources" s