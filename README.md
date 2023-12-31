# Notes during AD Troubleshooting Workshop

## Open Topics

- Pester 

## Todos

1. RC4 deadline?

    [November 2022 Out of Band update released! Take action! - Microsoft Community Hub](
    https://techcommunity.microsoft.com/t5/ask-the-directory-services-team/november-2022-out-of-band-update-released-take-action/bc-p/3700413/highlight/true).

1. Some domain controllers are under heavy load and it is not sure if the partner domain controllers in the same site experience the same load as well. Maybe applications target particular domain controllers because of hard settings. [Perfmon](https://learn.microsoft.com/de-de/windows-server/administration/windows-commands/perfmon) can help tracking the issue as well as monitoring the event log more closely.

1. NTLM uses RC4 and should be removed as well. Monitoring the usage of NTLM is recommended and plan to restrict it arroding to [Network security: Restrict NTLM: Audit NTLM authentication in this domain](https://learn.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/network-security-restrict-ntlm-audit-ntlm-authentication-in-this-domain)

1. There are old DNS SRV records of domain controllers decommisioned years ago. Are there processes cleaning up DNS on a regular basis? Windows DNS Servers have `DNS Scavening` for cleanip up orphaned records.

1. Maybe get rid of secondary zones and replicate the AD integrated zones to the entire forest.

1. How does the non-Microsoft DNS server system make sure, that dynamic updates are always secure? We did not find any traces of Kerberos authentication to the DNS servers.

1. There are numerous accounts with Kerberos unconstained delegation activated. This should be switched to contained delegation.

1. Configuring preferred bridgeheard servers is not required and makes the configuration more complex. Especially defining only one preferred bridgehead server is not recommended.

1. Sitelink costs are different for unknown reason. The sitelink cost seems to not follow a strict rule.

1. Some sitelinks connect only one site, others more than 2. This should be cleaned up.

1. Consider enabling change notification on site links to eliminate replication delays ([Change Notifications in Active Directory Domain Services](https://learn.microsoft.com/en-us/windows/win32/ad/change-notifications-in-active-directory-domain-services)).

1. There is no dedicated monitoring pack deployed in Nagios to monitor the ADDS specific events and disgnostic data. Something simiar like the [Microsoft System Center Management Pack for ADDS](https://www.microsoft.com/en-us/download/details.aspx?id=54525) is recommended. The following exvent IDs should be monitored:

   - 1311
   - 1789
   - 1865
   - 1925
   - 1308
   - 1566
   - 1567
   - 1864


EnableForwarderReordering

## Useful tools and links

- [**AutomatedLab**](https://automatedlab.org/en/latest/)
- [AutomatedLab.Common](https://www.powershellgallery.com/packages/AutomatedLab.Common/2.3.17) - Generic library with useful functions
- [**Introduction to PowerShell Functions and Modules**](https://github.com/raandree/PowerShellTraining)
- [**PowerShell Module Generation Blueprint**](https://github.com/gaelcolas/Sampler)
- [VSCode](https://code.visualstudio.com/download)
- [Git](https://git-scm.com/downloads)
- [regex101: build, test, and debug regex](https://regex101.com/)
- [GitLense](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens)
- [Microsoft Active Directory Topology Diagrammer](http://web.archive.org/web/20200802184044/https://www.microsoft.com/en-us/download/confirmation.aspx?id=13380) (This tool is no longer offically available, archive.org has made a copy)
- [draw.io](https://www.drawio.com/) as a replacement for Microsoft Visio
- [NTFSSecurity PowerShell Module](https://www.powershellgallery.com/packages/NTFSSecurity/4.2.6) for managing NTFS permissions in a comfortable and effective way in PowerShell
- [Kerberos 101 Workshop](https://github.com/raandree/Kerberos101)
- [How to find expensive, inefficient and long running LDAP queries in Active Directory](https://techcommunity.microsoft.com/t5/core-infrastructure-and-security/how-to-find-expensive-inefficient-and-long-running-ldap-queries/ba-p/257859)
- [Prevent Branch Office Domain Controllers from registering generic DNS Records and Netmask Ordering](https://blog.matrixpost.net/prevent-branch-office-domain-controller-from-registering-generic-dns-records-and-netmask-ordering/)
- [PowerShell Practice and Style](https://github.com/PoshCode/PowerShellPracticeAndStyle/blob/d1c6ae146b1060ec4844afc393161c6237bd85a7/Style-Guide/Code-Layout-and-Formatting.md)
- [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer)
## Notes

- PowerShell is object oriented where as the cmd shell is text based. Retrieving the IP addresses from `ipconfig.exe` (text) is far more difficult that getting it from the result of a cmdlet (object)

    ```powershell
    ipconfig.exe | ForEach-Object { if ($_ -match 'IPv4 Address([\. :]+)(?<IpAddress>[\d\.]+)') { $Matches.IpAddress } }

    (Get-NetIPAddress).IPAddress
    ```

- Get all domain controllers within the current forest:

    ```powershell
    $f = Get-ADForest
    $dcs = foreach ($domain in $f.Domains)
    {
        $domain = Get-ADDomain -Identity $domain
        foreach ($dc in $domain.ReplicaDirectoryServers)
        {
        Get-ADDomainController -Identity $dc -Server $domain.DNSRoot
        }
    } 
    ```

- Get a list of all AD replication site links with the site count and site name:

    ```powershell
    Get-ADReplicationSiteLink -Filter * | 
        Format-Table -Property Name , Cost, ReplicationFrequencyInMinutes, 
        @{ Name = 'SiteCount'; Expression = { 
                $_.SitesIncluded.Count } 
        }, 
        @{ Name = 'SitesIncluded'; Expression = { 
                $_.SitesIncluded | ForEach-Object { 
            ($_ -split ',')[0] | 
                        ForEach-Object {
                            $_.Substring(3)
                        } } } 
            }
    ```

- Replicate all domain controllers (push and pull)

    ```cmd
    REPADMIN /viewlist * > DCs.txt

    FOR /F "tokens=3" %%a IN (DCs.txt) DO CALL REPADMIN /SyncAll /AeP %%a

    DEL DCs.txt

    REPADMIN /ReplSum
    ```

- Get all DNS Server scavening setting

    ```powershell
    $f = Get-ADForest
    $dcs = foreach ($domain in $f.Domains)
    {
        $domain = Get-ADDomain -Identity $domain
        foreach ($dc in $domain.ReplicaDirectoryServers)
        {
        Get-ADDomainController -Identity $dc -Server $domain.DNSRoot
        }
    }

    $dnsServers = Invoke-Command -ComputerName $dcs.HostName -ScriptBlock { Get-DnsServer }

    $dnsServers | Format-Table -Property PSComputerName, @{ Name = 'ScavengingInterval'; Expression = { $_.ServerScavenging.ScavengingInterval } }
    ```

- Get all DNS Server Zones and aging settings

    ```powershell
    Get-DnsServerZone | Get-DnsServerZoneAging | Format-Table -Property *
    ```

- Get all Kerberos tickets from all logon sessions:

    ```powershell
    $sessions = klist sessions
    $pattern = '\[(\d+)\] Session \d \d:(?<LowPart>0)x(?<HighPart>[a-f0-9]+)'

    $sessions = foreach ($line in $sessions)
    {
        if ($line -match $pattern)
        {
            New-Object PSObject -Property @{
                LowPart = $Matches.LowPart
                HighPart = $Matches.HighPart
            }
        }
    }

    $sessionsTickets = foreach ($session in $sessions)
    {
        $result = New-Object PSObject -Property @{
            Session = "$($session.LowPart)x$($session.HighPart)"
            Tickets = klist tickets -lh $session.LowPart -li $session.HighPart
        }
    
        Write-Host "'klist tickets -lh $($session.LowPart) -li $($session.HighPart)' knows about $($result.Tickets.Count) tickets"

        $result
    }

    #to view all tickets
    $sessionsTickets.Tickets 
    ```

- Display the version, last change time and ogininating domain controller of all attributes of an object

    ```powershell
    $o = Get-ADObject -IncludeDeletedObjects -Filter 'SamAccountName -eq "g1"'

    Get-ADReplicationAttributeMetadata -Object $o -Properties * -Server f1dc1 -IncludeDeletedObjects |
    Format-Table -Property AttributeName, Version, LastOriginatingChangeTime, LastOriginatingChangeDirectoryServerIdentity
    ```

- Get the local group membership translates from SID to name

    ```powershell
    $wi = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $wi.Groups | ForEach-Object {
        $_.Translate([System.Security.Principal.NTAccount])
    }

    $si = New-Object System.Security.Principal.SecurityIdentifier('S-1-5-21-2033787110-292873494-3235488292-3509')
    $si.Translate([System.Security.Principal.NTAccount])
    ```

- Get the group count of all the first 500 user accounts:

    ```powershell
    $users = Get-ADUser -Filter * -ResultSetSize 500 | ForEach-Object {
        $_ | Add-Member -MemberType ScriptProperty -Name GroupCount -Value {
            ($this | Get-ADAccountAuthorizationGroup).Count
        } -PassThru -Force
    }

    $users | Format-Table -Property Name, GroupCount
    ```

- Install software on a remote machine with PowerShell

    ```powershell
    #Install-LabSoftwarePackage -Path D:\LabSources\SoftwarePackages\npp.8.5.1.Installer.x64.exe -CommandLine /S -ComputerName DSCDC01

    $cred = [pscredential]::new('contoso\install', ('Somepass1' | ConvertTo-SecureString -AsPlainText -Force))
    $s = New-PSSession -ComputerName DSCDC01 -Credential $cred
    Copy-Item -Path D:\LabSources\SoftwarePackages\npp.8.5.1.Installer.x64.exe -Destination C:\ -ToSession $s

    $fi = Get-Command -Name Add-FunctionToPSSession
    Add-FunctionToPSSession -Session $s -FunctionInfo $fi

    Invoke-Command -Session $s -ScriptBlock {
        #The function 'Install-SoftwarePackage' is defined in the 'AutomatedLab.Common' module
        Install-SoftwarePackage -Path C:\npp.8.5.1.Installer.x64.exe -CommandLine /S -
    }
    ```
