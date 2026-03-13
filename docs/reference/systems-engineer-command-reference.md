# Systems Engineer Command Reference

This document collects high-value commands for everyday systems engineering work.

## Linux Service and Health Checks

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

## Linux Troubleshooting

~~~bash
ping <host>
nslookup <host>
traceroute <host>
curl -v http://<host>:<port>
nc -zv <host> <port>
getenforce
firewall-cmd --list-all
last
who
~~~

## Windows Operations

~~~powershell
Get-Service
Get-Process | Sort-Object CPU -Descending | Select-Object -First 20
Get-Volume
Get-EventLog -LogName System -Newest 100
Get-WinEvent -LogName Security -MaxEvents 50
Test-NetConnection <host> -Port 3389
Get-NetIPAddress
Get-NetRoute
Restart-Service -Name <service>
~~~

## Azure CLI

~~~bash
az login
az account show
az group list -o table
az vm list -o table
az vm show --resource-group <rg> --name <vm> -o json
az vm get-instance-view --resource-group <rg> --name <vm>
az resource list -o table
az monitor activity-log list --max-events 20
~~~

## Terraform

~~~bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform show
terraform output
terraform state list
terraform refresh
~~~

## Security and Compliance

~~~bash
oscap xccdf eval ...
oscap xccdf generate report ...
nessuscli ...
rpm -qa
yum check-update
dnf check-update
~~~

## Usage Notes
- Capture outputs during incident review and change validation
- Prefer approved bastions, jump hosts, and admin workstations
- Document command usage when a fix is applied in production
