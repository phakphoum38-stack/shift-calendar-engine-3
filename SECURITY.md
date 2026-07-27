# Security Policy

## Reporting

Do not open a public issue containing credentials, tokens, personal roster
data, or a working exploit. Contact the repository owner privately through the
GitHub security advisory interface.

## Baseline controls

- no secrets committed to source
- dependency vulnerability scanning
- static secret/configuration scanning
- least-privilege provider scopes
- confirmation before destructive or bulk actions
- user-only Google Calendar synchronization
- versioned local persistence with controlled decoding failures

Mobile signing, production OAuth configuration, and release credentials remain
outside the repository and must use GitHub Environments and encrypted secrets.
