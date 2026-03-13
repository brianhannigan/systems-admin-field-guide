# Systems Engineer Cheat Sheet

## Linux Quick Commands

~~~bash
hostnamectl
uname -a
ip addr
ss -tulpn
systemctl status <service>
journalctl -u <service> -n 100
df -h
free -h
top
~~~

## Windows Quick Checks

~~~powershell
Get-Service
Get-EventLog -LogName System -Newest 50
Get-Process | Sort-Object CPU -Descending | Select-Object -First 20
Get-Volume
Test-NetConnection
~~~

## Azure Quick Commands

~~~bash
az login
az account show
az vm list -o table
az group list -o table
az resource list -o table
~~~

## Terraform Quick Commands

~~~bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform show
terraform state list
~~~

## Troubleshooting Flow

1. Confirm scope
2. Confirm recent changes
3. Check service health
4. Check logs
5. Check network reachability
6. Validate dependencies
7. Test fix
8. Document outcome
