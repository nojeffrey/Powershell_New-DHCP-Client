## New-DHCP-Client-Powershell
- Sends out an email when a new DHCP client is seen for the first time.
- The first time running this it will create the directory structure C:\DHCP and the file DHCPList.txt if these do not exist, and run for the first time creating a benchmark.
- For the first few days it should be noisey as people come and go from wifi/network.
- Tested against Server2008r2 DHCP Server(non cluster) from a Windows 10 box
- Run this from either Windows 10, or Server 2012 as Get-DhcpServerv4Scope and Get-DhcpServerv4Lease functions are only available in I think Powershell 5.x
- When adding to Task Scheduler, you need to use domain admin privileges
- Modify the first 4 variables to suit your environment.
