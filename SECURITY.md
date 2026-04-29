# Security Policy

## Reporting a vulnerability

If you've found a security issue in any Mossworks Labs project, please **do not open a public issue**.

Use GitHub's [private vulnerability reporting](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing-information-about-vulnerabilities/privately-reporting-a-security-vulnerability) on the affected repo:

1. Go to the repo's **Security** tab.
2. Click **Report a vulnerability**.
3. Fill in what you observed, the impact, and a reproduction if you have one.

We aim to acknowledge new reports within 3 business days and to issue a fix or mitigation plan within 14 days for high-severity issues.

## Scope

In scope:
- All public repos under [Mossworks-Labs](https://github.com/Mossworks-Labs).
- Container images published under [`ghcr.io/mossworks-labs`](https://github.com/orgs/Mossworks-Labs/packages).
- The hosted documentation at [docs.mossworks.io](https://docs.mossworks.io/).

Out of scope:
- Third-party dependencies — file upstream and reference the CVE here so we can pin / patch.
- Self-hosted deployments running unmodified releases — config issues belong in normal issues, not security reports.
- Brute-force or denial-of-service against test infrastructure.

## Disclosure

We'll coordinate disclosure timing with the reporter. Default policy is a public advisory once a fixed release is available, with credit to the reporter unless they ask to remain anonymous.
