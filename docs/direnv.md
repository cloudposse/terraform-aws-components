# direnv

Origin: 3rd party project (https://github.com/direnv/direnv)

Problem it solves:
- Too many ENV vars in a global namespace (in the geodesic shell).

`direnv`:
- is more than just a way of setting environment variables.

- is a declarative, structured, heirarchical (by way of directory
tree) (similar to `.gitignore`) way to set ENV vars when you `cd` to a
particular directory.

- allows environment variables to contain interpolations, so variables
can reference other variables, and use shell `functions()`, all of which get
resolved at runtime when you change (`cd`) directories.

To promote greater reuse, `direnv` has a concept of a standard library
(called 'stdlib', see next section) users can hook into that, and add their
own functions.

This meshes well with our use of `tfenv`, by way of a stdlib function that
drives usage of `tfenv` (see `use terraform`, below).

## stdlib usage:

`direnv` has it's own "stdlib".
See: 
- https://github.com/direnv/direnv/blob/master/README.md#the-stdlib
- https://github.com/direnv/direnv/blob/master/stdlib.sh

In each of our `.envrc` files, we invoke stdlib's `use` function to
load our standard library modules, in this order:

```
use terraform
use tfenv
use atlantis
```

### `use terraform`:

Should always be called before 'tfenv'

This function populates the variables that the `terraform` binary
requires to be set before it can read remote state.  Terraform needs
these set before it can do anything, because reading remote state
happens very early in the command execution process.

Without naming them, the variables we set affect:
- state bucket path prefix, region, credentials (profile/role)
- project prefix in a state bucket
- state bucket region

Using direnv, we can programmatically derive the appropriate terraform
variable runtime settings based on attributes of the current
directory, such as:
- directory name
- directory parent name
- there's more -- read the code


### `use tfenv`:

Allows us to invoke the `tfenv` exporter function in our current shell,
which allows us to avoid the use of wrapper scripts for terraform or other tools.

Avoiding wrappers is ideal, because it maximizes interop with 3rd party tools.

By avoiding any wrappers for 'terraform', we remain 100% compatible
with tools that are themselves wrappers for 'terraform'.  Case in
point: 'terragrunt' (which is a binary wrapper for 'terraform').

### `use atlantis`:

Should always be called after tfenv and terraform.
Allows us to programatically set the Atlantis PLANFILE in environments which run Atlantis.
