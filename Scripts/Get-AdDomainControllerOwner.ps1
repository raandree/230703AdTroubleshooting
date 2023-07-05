#Requires -Modules ADSec

$f = Get-ADForest

$dcs = foreach ($domain in $f.Domains)
{
    $domain = Get-ADDomain -Identity $domain
    foreach ($dc in $domain.ReplicaDirectoryServers)
    {
        Get-ADDomainController -Identity $dc -Server $domain.DNSRoot
    }
}

foreach ($dc in $dcs)
{
    $sd = Get-AdsAcl -Path $dc.ComputerObjectDN -Server $dc.Domain

    [pscustomobject]@{
        DcName = $dc.HostName
        Domain = $dc.Domain
        Forest = $dc.Forest
        Owner = $sd.Owner
    }
}
