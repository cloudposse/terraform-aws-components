#!/bin/bash
 
# Remove all versions and delete markers for each object
OBJECT_VERSIONS=$(aws --output text s3api list-object-versions --bucket "$1" | grep -E '^VERSIONS|^DELETEMARKERS')

if [ $? -ne 0 ]; then
	echo "Aborting"
	exit 1
fi

while read -r OBJECT_VERSION; do
	if [[ "$OBJECT_VERSION" == DELETEMARKERS* ]]; then
		KEY=$(echo $OBJECT_VERSION | awk '{print $3}')
		VERSION_ID=$(echo $OBJECT_VERSION | awk '{print $5}')
	else
		KEY=$(echo $OBJECT_VERSION | awk '{print $4}')
		VERSION_ID=$(echo $OBJECT_VERSION | awk '{print $8}')
	fi
	if [ -n "${KEY}" ] && [ -n "${VERSION_ID}" ]; then
		aws s3api delete-object --bucket $1 --key $KEY --version-id $VERSION_ID >/dev/null
	fi
done <<< "$OBJECT_VERSIONS"
 
# Remove the bucket with --force option to remove any remaining files without versions.
aws s3 rb --force s3://$1
