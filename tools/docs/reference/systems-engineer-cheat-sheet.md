# Systems Engineer Cheat Sheet

## Linux Quick Commands

~~~bash
hostnamectl
uname -a
ip addr
ip route
ss -tulpn
systemctl status <service>
journalctl -u <service> -n 100
df -h
free -h
top
ps -ef
~~~

## Windows Quick Checks

~~~powershell
Get-Service
Get-Process | Sort-Object CPU -Descending | Select-Object -First 20
Get-Volume
Get-EventLog -LogName System -Newest 50
Test-NetConnection <host> -Port 3389
~~~

## Azure Quick Commands

~~~bash
az login
az account show
az group list -o table
az vm list -o table
az vm show --resource-group <rg> --name <vm> -o json
~~~

## Terraform Quick Commands

~~~bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform state list
~~~
