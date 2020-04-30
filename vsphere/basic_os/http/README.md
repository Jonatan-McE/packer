If running packer from a WSL2 instance on windows, you'll need allow it in the firewall and setup a port-forward the http server.

- netsh advfirewall firewall add rule name="Allow localhost port 8000" dir=in action=allow protocol=TCP localport=8000
- netsh interface portproxy add v4tov4 listenport=8000 listenaddress=0.0.0.0 connectport=8000 connectaddress=172.19.98.x
