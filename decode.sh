#!/bin/sh
# usage: decode.sh json-file module_id json_variable 
jq  ".module_statuses[] | select(.module_id==$2) | { soc: .$3 }"  <$1 | grep : | awk '{ print $2 }'
