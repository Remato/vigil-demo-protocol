# Known issues

Issues the team already knows about. Reports of these are not eligible for a bounty.

## Fee recipient can be changed by anyone

`Vault.setFeeRecipient(address)` has no access control, so any account can redirect the
withdrawal fee to itself. Fees are zero at launch and the function will be restricted to the
owner before fees are enabled.
