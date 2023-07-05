$enums = @"
using System;

[Flags]
public enum UserAccountControl
{
    Script = 1,
    AccountDisabled = 2,
    HomeDirectoryRequired = 8,
    LockedOut = 16,
    PasswordNotRequired = 32,
    PasswordCannotChange = 64,
    EncryptedTextPasswordAllowed = 128,
    TempDuplicateAccount = 256,
    NormalAccount = 512,
    InterdomainTrustAccount = 2048,
    WorkstationTrustAccount = 4096,
    ServerTrustAccount = 8192,
    DontExpirePassword = 65536,
    MnsLogonAccount = 131072,
    SmartcardRequired = 262144,
    TrustedForDelegation = 524288,
    NotDelegated = 1048576,
    UseDesKeyOnly = 2097152,
    DontRequirePreAuthentication = 4194304,
    PasswordExpired = 8388608,
    TrustedToAuthForDelegation = 16777216,
    PartialSecretsAccount = 67108864
}
"@

Add-Type -TypeDefinition $enums

Write-Host "Accounts enabled for Kerberos Delegation (non-constrained)" -ForegroundColor DarkGreen
$accountsEnabledForKerberosDelegation = Get-ADObject -LDAPFilter "(&(objectCategory=*)(userAccountControl:1.2.840.113556.1.4.803:=$([int][UserAccountControl]::TrustedForDelegation)))" -Properties UserAccountControl, msDS-AllowedToDelegateTo
$accountsEnabledForKerberosDelegation | Format-Table Name,UserAccountControl,@{ Label = "Readable UserAccountControl"; Expression = { [UserAccountControl]$_.UserAccountControl } },msDS-AllowedToDelegateTo -AutoSize -Wrap

Write-Host "Accounts enabled for Kerberos Constrained Delegation" -ForegroundColor DarkGreen
$accountsEnabledForKerberosConstrainedDelegation = Get-ADObject -LDAPFilter '(&(objectCategory=*)(msDS-AllowedToDelegateTo=*))' -Properties UserAccountControl,msDS-AllowedToDelegateTo
$accountsEnabledForKerberosConstrainedDelegation | Format-Table Name,UserAccountControl,@{ Label = "Readable UserAccountControl"; Expression = { [UserAccountControl]$_.UserAccountControl } }, msDS-AllowedToDelegateTo -AutoSize –Wrap

Write-Host "Accounts enabled for Kerberos Protocol Transition" -ForegroundColor DarkGreen
$accountsEnabledForKerberosProtocolTransition = Get-ADObject -LDAPFilter "(&(objectCategory=*)(userAccountControl:1.2.840.113556.1.4.803:=$([int][UserAccountControl]::TrustedToAuthForDelegation)))" -Properties UserAccountControl, msDS-AllowedToDelegateTo
$accountsEnabledForKerberosProtocolTransition | Format-Table Name,UserAccountControl,@{ Label = "Readable UserAccountControl"; Expression = { [UserAccountControl]$_.UserAccountControl } },msDS-AllowedToDelegateTo -AutoSize -Wrap

Write-Host "Accounts that are sensitive and cannot be delegated" -ForegroundColor DarkGreen
$accountsCannotBeDelegated = Get-ADObject -LDAPFilter "(&(objectCategory=*)(userAccountControl:1.2.840.113556.1.4.803:=$([int][UserAccountControl]::NotDelegated)))" -Properties UserAccountControl
$accountsCannotBeDelegated | Format-Table Name,UserAccountControl,@{ Label = "Readable UserAccountControl"; Expression = { [UserAccountControl]$_.UserAccountControl } } -AutoSize -Wrap