# Notes during AD Troubleshooting Workshop

## Todos

1. RC4 deadline?

    [November 2022 Out of Band update released! Take action! - Microsoft Community Hub](
    https://techcommunity.microsoft.com/t5/ask-the-directory-services-team/november-2022-out-of-band-update-released-take-action/bc-p/3700413/highlight/true).

1. Some domain controllers are under heavy load and it is not sure if the partner domain controllers in the same site experience the same load as well. Maybe applications target particular domain controllers because of hard settings. [Perfmon](https://learn.microsoft.com/de-de/windows-server/administration/windows-commands/perfmon) can help tracking the issue as well as monitoring the event log more closely.

1. NTLM uses RC4 and should be removed as well. Monitoring the usage of NTLM is recommended and plan to restrict it arroding to [Network security: Restrict NTLM: Audit NTLM authentication in this domain](https://learn.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/network-security-restrict-ntlm-audit-ntlm-authentication-in-this-domain)

## Useful tools and links

- [AutomatedLab](https://automatedlab.org/en/latest/)
- [VSCode](https://code.visualstudio.com/download)
- [Git](https://git-scm.com/downloads)
- [regex101: build, test, and debug regex](https://regex101.com/)

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
