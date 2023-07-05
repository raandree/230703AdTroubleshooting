function ConvertTo-Sid
{
    param (
        [Parameter(Mandatory = $true)]
        [string]$Sid
    )

    $si = New-Object System.Security.Principal.SecurityIdentifier($Sid)
    $Account = $si.Translate([System.Security.Principal.NTAccount])
    $Account.Value
}

function ConvertTo-AccountName
{
    param (
        [Parameter(Mandatory = $true)]
        [string]$AccountName
    )

    $a = New-Object System.Security.Principal.NTAccount($AccountName)
    try
    {
        $Sid = $a.Translate([System.Security.Principal.SecurityIdentifier])
        $Sid.Value
    }
    catch
    {
        Write-Error "Failed to convert $AccountName to SID"
        return
    }

}
