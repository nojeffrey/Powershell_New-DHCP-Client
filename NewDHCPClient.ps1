#v1.01
#Written by nojeffrey(https://github.com/nojeffrey)
#Email if new DHCP client is found on Windows DHCP Server, tested on 2008r2
#Modify these 4 variables to suit:

$DHCPServer = "yourDHCPserver"
$SMTPServer = "yourMAILserver"
$from = "DHCP@yourcompany.com"
$to = "you@yourcompany.com"


#Test if C:\DHCP directory exists, if not; create the dir and run for the first time, save output to C:\DHCP\DHCPList.txt
if((Test-Path C:\DHCP) -eq 0){
    New-Item -ItemType Directory -Path C:\DHCP
    Get-DhcpServerv4Scope -ComputerName $DHCPServer | Get-DhcpServerv4Lease -ComputerName $DHCPServer | Select-Object -ExpandProperty Hostname | Sort-Object -Unique | Out-File "C:\DHCP\DHCPList.txt"
    }


$old = Get-Content "C:\DHCP\DHCPList.txt" | Sort-Object -Unique
$new = Get-DhcpServerv4Scope -ComputerName $DHCPServer | Get-DhcpServerv4Lease -ComputerName $DHCPServer | Select-Object -ExpandProperty Hostname | Sort-Object -Unique

#Compare difference
$newDHCPtoWrite = diff -ReferenceObject $old -DifferenceObject $new
$ListToEmail = $null
$count = 0


ForEach ( $x in $newDHCPtoWrite){
    #I only care if new DHCP Client(=>), ignore clients that drop off DHCP(<=)
    if($x.SideIndicator -eq "=>") {
        $count += 1
        $ListToEmail += "</br>" + $x.InputObject
        #Append newly found Clients to DHCPList.txt
        $x.InputObject | Out-File "C:\DHCP\DHCPList.txt" -Append
        }
}

#If no new DHCP clients, exit script now
if($count -eq 0){
    Exit
    }

#Send email
$subject = "DHCP: New Client(s)"
$body = "There is " + $count + " never before seen DHCP Clients: "+ $ListToEmail 
$mailer = new-object Net.Mail.SMTPclient($SMTPServer)
$msg = new-object Net.Mail.MailMessage($from,$to,$subject,$body)
$msg.IsBodyHTML = $true
$mailer.send($msg)