#!/usr/bin/env bash
#
# Retrieve discord messages from MULTIPLE channels in MULTIPLE servers
# This requires the same deps as ./main.sh
# This is a wrapper around ./main.sh which handles one channel
#
# Author: hxuu <an.mokhtari@esi-sba.dz>
# Date: Sep 30, 2025
# Reference: https://curl.se/docs/http3.html

usage() {
    echo "Usage: $0 -t <token> -i <data_file>"
    echo
    echo "options:"
    echo ' -h       Print help'
    echo ' -t       auth token'
    echo ' -i       data file (check index.txt)'
}

token=
data_file=
parse-options() {
    while getopts 'ht:i:' opt; do
        case "$opt" in
            h) usage; exit 0;;
            t) token="$OPTARG";;
            i) data_file="$OPTARG";;
            *) usage >&2; exit 1;;
        esac
    done
}

main() {
    while IFS=, read -r name channel_id; do
        if [[ "$name" =~ "repo" ]]; then
            target="${name%/*}"
            repo_link="$channel_id"

            mkdir -p "$target"
            echo $repo_link > "${name}.txt";
        else
            # main.sh is forking another process. Have to export
            export file="${name}_${channel_id}.json"
            ./main.sh -t "$token" -c "$channel_id" || exit 1
            echo "[+] Sucess. Check <${file}>"
        fi
    done < ${data_file}
}

parse-options "$@"

if [[ -z "$token" || -z "$data_file" ]]; then
    echo "Error: both -t (token) and -i (data_file) are required." >&2
    usage
    exit 1
fi

main
