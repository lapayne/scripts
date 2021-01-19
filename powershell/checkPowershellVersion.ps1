param(
[String[]] $servernames = @("server1","server2","server3"), # server name array

[String] $message) # stores email body


		foreach ($server in $servernames)
		{
			Write-Progress -activity "Running on $server" -status "Please wait ..."
			if (Test-Connection $server)
			{
				Write-Verbose " [$($MyInvocation.InvocationName)] :: Processing $server"
				try
				{
					$PSVersion = Invoke-Command -Computername $server -Scriptblock { $PSVersionTable.psversion } 
					$PSVersion
				}
				catch
				{
					Write-Verbose " Host [$server] Failed with Error: $($Error[0])"
				}
			}
			else
			{
				Write-Verbose " Host [$server] Failed Connectivity Test "
			}
		}

