# tfenv

Original Author: cloudposse

Closest cousin is `env`

-- 'tfenv' tool is used to manage just the environment vars intended
for 'terraform' to consume at runtime.

- link to terraform env usage docs

terraform has two variable types
- variable-related TF_VAR_*
- flag-related TF_CLI_*

tfenv interacts with these two ^^^^ variable types

- debugging (not addressed)



- tunables
- security considerations:
  - black/white listing of variables that are mapped


two modes of operation

- wrapper (user passes a command to run)
- exporter (emit shell commands, that set shell variables on stdout, suitable for shell eval)

CP predomenant usage uses the exporter mode

