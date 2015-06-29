#v1.02
#Written by nojeffrey(https://github.com/nojeffrey)
#Email if new DHCP client is found on Windows DHCP Server, tested against 2008r2 DHCP server,
#Run this from either a Windows 10, or Server2012 box, Get-DhcpServerv4Scope an Get-DhcpServerv4Lease functions are only available in I think Powershell 5.x
#Modify these 4 variables to suit:

$DHCPServer = "yourDHCPserver"
$SMTPServer = "yourMAILserver"
$from = "DHCP@yourcompany.com"
$to = "you@yourcompany.com"

#Test if C:\DHCP directory exists, if not; create the dir and run for the first time, save output to C:\DHCP\DHCPList.txt
if((Test-Path C:\DHCP) -eq 0){
    New-Item -ItemType Directory -Path C:\DHCP
    Get-DhcpServerv4Scope -ComputerName $DHCPServer | Get-DhcpServerv4Lease -ComputerName $DHCPServer | Select-Object -ExpandProperty Hostname |Sort-Object -Unique | Out-File "C:\DHCP\DHCPList.txt"
}

#Test if DHCPList.txt exists, if not run for first time(needed if only the directory exists, and not the file)
if((Test-Path C:\DHCP\DHCPList.txt) -eq 0){
    Get-DhcpServerv4Scope -ComputerName $DHCPServer | Get-DhcpServerv4Lease -ComputerName $DHCPServer | Select-Object -ExpandProperty Hostname |Sort-Object -Unique | Out-File "C:\DHCP\DHCPList.txt"
}


$old = Get-Content "C:\DHCP\DHCPList.txt" | Sort-Object -Unique
$new = Get-DhcpServerv4Scope -ComputerName $DHCPServer | Get-DhcpServerv4Lease -ComputerName $DHCPServer | Select-Object -ExpandProperty Hostname | Sort-Object -Unique

#Compare difference
$newDHCPtoWrite = diff -ReferenceObject $old -DifferenceObject $new
$ListToEmail = $null
$count = 0


foreach ( $x in $newDHCPtoWrite){
    #I only care if new DHCP Client(=>), ignore clients that drop off DHCP(<=)
    if($x.SideIndicator -eq "=>") {
        $count += 1
        $ListToEmail += "</br>" + $x.InputObject
        #Append newly found Clients to DHCPList.txt
        $x.InputObject | Out-File "C:\DHCP\DHCPList.txt" -Append
    }
}

#Send email if count > 0
if($count){
#Send email
    $subject = "DHCP: New Client(s)"
    $body = "There is " + $count + " never before seen DHCP Client(s): "+ $ListToEmail
    $mailer = new-object Net.Mail.SMTPclient($SMTPServer)
    $msg = new-object Net.Mail.MailMessage($from,$to,$subject,$body)
    $msg.IsBodyHTML = $true
    $mailer.send($msg)
}

else{
    break
}