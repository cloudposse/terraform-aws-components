## Changes in PR #889, expected Component version ~1.334.0

### `team` replaced with `team_options`

The `team` variable has been replaced with `team_options` to reduce confusion. The component only ever creates at most
one team, with the name specified in the `name` variable. The `team` variable was introduced to provide a single object
to specify other options, but was not implemented properly.

### Team membership now managed by this component by default

Previously, the default behavior was to not manage team membership, allowing users to be managed via the Opsgenie UI.
Now the default is to manage via the `members` input. To restore the previous behavior, set
`team_options.ignore_members` to `true`.
