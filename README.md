If running packer from a WSL2 instance on windows, you'll need allow it in the firewall and setup a port-forward the http server.

- netsh advfirewall firewall add rule name="Allow localhost port 8000" dir=in action=allow protocol=TCP localport=8000
- netsh interface portproxy add v4tov4 listenport=8000 listenaddress=0.0.0.0 connectport=8000 connectaddress=172.19.98.x

---------------------------------------------------------------------------------------------------------------------------------

#All the ports you want to forward separated by coma
$ports=@(8000..8009)

#[Static ip]
$listenaddress='0.0.0.0'
$connectaddress='172.18.27.38'

#Remove Firewall Exception Rules
Remove-NetFireWallRule -DisplayName 'WSL 2 Firewall Rule'

#adding Exception Rules for inbound and outbound Rules
New-NetFireWallRule -DisplayName 'WSL 2 Firewall Rule' -Direction Inbound -LocalPort $ports -Action Allow -Protocol TCP

for( $i = 0; $i -lt $ports.length; $i++ ){
  $port = $ports[$i];
  netsh interface portproxy delete v4tov4 listenport=$port listenaddress=$listenaddress
  netsh interface portproxy add v4tov4 listenport=$port listenaddress=$listenaddress connectaddress=$connectaddress
}
