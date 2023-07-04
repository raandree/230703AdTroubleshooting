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
