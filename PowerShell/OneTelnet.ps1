# You can use this script to test connectivity
# to any host and port number, Even using servers variable		
# you can check connectivity on multiple servers.		
#
		Write-Host -Separator `n
		#$Servers = (gc File Path)
		$Servers = Read-Host -Prompt "Enter Server IP or Hostname"
		$Port = Read-Host -Prompt "Enter Port Number To Test"

		ForEach ($Server in $Servers)
		{ 
			Write-Host -Separator `n
			Write-Host Checking server $Server on $Port
				Try
				{			
					$Connected = (New-Object System.Net.Sockets.TcpClient("$Server", $Port)).Connected
					Write-Host -Separator `n
					If ($Connected = "true") {Write-Host Connected status is $Connected -ForegroundColor Green}
					Write-Host -Separator `n
				}
				Catch
				{
				Write-Host $_.Exception.Message -ForegroundColor Yellow
				Write-Host -Separator `n
				}
			
		}
		


