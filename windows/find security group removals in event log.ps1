$test = get-winevent -filterhashtable @{Logname='Security';ID=4733} -maxevents 3