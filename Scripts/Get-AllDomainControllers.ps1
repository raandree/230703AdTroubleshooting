$f = Get-ADForest

$dcs = foreach ($domain in $f.Domains)
{
    $domain = Get-ADDomain -Identity $domain
    foreach ($dc in $domain.ReplicaDirectoryServers)
    {
        Get-ADDomainController -Identity $dc -Server $domain.DNSRoot
    }
} 
