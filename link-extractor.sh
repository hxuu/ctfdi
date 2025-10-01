#!/usr/bin/env bash
#
# Extract link from json dump using jq
# Writeups are generally linked rather than written (some people do type out their writeups,
# and that's why the id is provided for back-reference)
# Deps:
#   - jq
#
# Author: hxuu <an.mokhtari@esi-sba.dz>
# License: GPL

# Taken from: https://daringfireball.net/2010/07/improved_regex_for_matching_urls
pattern='(?i)\b((?:https?://|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'\''".,<>?«»“”‘’]))'

if (( $# < 1 )); then
    tput setaf 1
    echo 'Usage: $0 <file.json>' >&2
    tput sgr0
    exit 1
fi

# I'm not validating the arguments I know
jq -c -s --arg pattern "$pattern" \
    'add[] | select(.content | test($pattern)) | { id, content, timestamp }' < "$1"
