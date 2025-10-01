#!/usr/bin/env bash
#
# Automatically generate _site/ directory
# based on all chat dumps from the ctfs/ directory
#
# Author: hxuu <an.mokhtari@esi-sba.dz>
# License: GPL

chat_dumps=(ctfs/**/*)

for chat in "${chat_dumps[@]}"; do
    [[ "$chat" =~ 'repo' || -e "${chat%.json}.html" ]] && continue
    ./build.sh "${chat}"
    sleep 60
done
