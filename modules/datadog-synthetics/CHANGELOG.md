## Changes approximately v1.329.0

### API Schema accepted

Test can now be defined using the Datadog API schema, meaning that the test definition
returned by
- `https://api.datadoghq.com/api/v1/synthetics/tests/api/{public_id}`
- `https://api.datadoghq.com/api/v1/synthetics/tests/browser/{public_id}`

can be directly used a map value (you still need to supply a key, though).

You can mix tests using the API schema with tests using the old Terraform schema.
You could probably get away with mixing them in the same test, but it is not recommended.

### Default locations

Previously, the default locations for Synthetics tests were "all" public locations.
Now the default is no locations, in favor of locations being specified in each test configuration,
which is more flexible. Also, since the tests are expensive, it is better to err on the side of
too few test locations than too many.
