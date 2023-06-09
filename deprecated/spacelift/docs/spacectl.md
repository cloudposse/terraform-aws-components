# spacectl

See docs https://github.com/spaceone-dev/spacectl

Install

```
⨠ apt install -y spacectl -qq
```

Setup a profile

```
⨠ spacectl profile login <org name>
Enter Spacelift endpoint (eg. https://unicorn.app.spacelift.io/): https://<github org>.app.spacelift.io
Select credentials type: 1 for API key, 2 for GitHub access token: 1
Enter API key ID: 01FKN...
Enter API key secret:
```

Listing stacks

```
spacectl stack list
```

Grab all the stack ids (use the JSON output to avoid bad chars)

```
spacectl stack list --output json | jq -r '.[].id' > stacks.txt
```

If the latest commit for each stack is desired, run something like this.

NOTE: remove the `echo` to remove the dry-run functionality

```
cat stacks.txt | while read stack; do echo $stack && echo spacectl stack set-current-commit --sha 25dd359749cfe30c76cce19f58e0a33555256afd --id $stack; done
```
