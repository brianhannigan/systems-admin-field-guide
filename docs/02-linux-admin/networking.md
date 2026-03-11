# Networking

## Purpose
Provide a repeatable approach for diagnosing Linux connectivity issues.

## Interface and Address Checks
```bash
ip addr
ip link
nmcli device status
hostname -I
```

## Routing and DNS
```bash
ip route
cat /etc/resolv.conf
nslookup example.com
dig example.com
```

## Port and Socket Checks
```bash
ss -tulpn
ss -anp
netstat -tulpn
```

## Connectivity Tests
```bash
ping 8.8.8.8
ping google.com
curl -I https://example.com
traceroute google.com
```

## Firewall Checks
```bash
firewall-cmd --state
firewall-cmd --list-all
firewall-cmd --list-ports
```

## Troubleshooting Workflow
1. Confirm the interface is up
2. Confirm the IP address is correct
3. Confirm the route table is sane
4. Test raw IP connectivity
5. Test DNS resolution
6. Check local listening ports
7. Check firewall rules
8. Validate application response

## Validation
- Interface is up
- IP and route are correct
- DNS resolves
- Port is listening
- Application responds
