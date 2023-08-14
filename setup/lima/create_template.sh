#!/bin/sh
#
# Just do simple templating

TEMPLATE=ubuntu-2204-lts.template.yaml
OUTPUT=ubuntu-2204-lts.yaml

cat "$TEMPLATE" | sed -e "s/REPOLIMABASE/$PWD/g" > "$OUTPUT"
