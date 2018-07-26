#!/usr/bin/env bash

echo "*WARNING* This script is probably out of date. Chamber is the only system of record for secrets"
echo "This file is just an example"
echo "*WARNING* Running this file as it is (without specifying the correct values) will destroy some secrets and break the environment"
echo "To add/update secrets, first edit this file and set values (replace XXXXXXXXXXXX with the correct values)"
echo "Then comment out 'exit 1' and run the file"
echo "Then undo the editing and uncomment 'exit 1'"
echo "Never commit this file with sensitive data. Run 'git reset --hard' if done accidentally"

exit 1


chamber write backing-services TF_VAR_POSTGRES_DB_NAME XXXXXXXXXXXX   # e.g. cloudposse
chamber write backing-services TF_VAR_POSTGRES_ADMIN_NAME XXXXXXXXXXXX   # e.g. cloudposse
chamber write backing-services TF_VAR_POSTGRES_ADMIN_PASSWORD XXXXXXXXXXXX
