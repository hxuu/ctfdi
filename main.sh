#!/usr/bin/env bash
#
# Retrieve discord messages from channel
# This requires the following:
#   * jq command to parse json
#   * a build of curl that supports HTTP/3 (with ability to fallback)
#   * a selfbot token (i.e. your discord token)
#
# Author: hxuu <an.mokhtari@esi-sba.dz>
# Date: Sep 29, 2025
# Reference: https://curl.se/docs/http3.html

usage() {
    echo "Usage: $0 -t <token> -c <channel_id>"
    echo
    echo "options:"
    echo ' -h       Print help'
    echo ' -t       auth token'
    echo ' -c       channel id'
}

token=
channel_id=
parse-options() {
    while getopts 'ht:c:' opt; do
        case "$opt" in
            h) usage; exit 0;;
            t) token="$OPTARG";;
            c) channel_id="$OPTARG";;
            *) usage >&2; exit 1;;
        esac
    done
}

main() {
    local -A headers

    # define headers
    headers["accept-language"]='en-US,en;q=0.9'
    headers["User-Agent"]="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36"
    headers["cache-control"]="no-cache"
    headers["Authorization"]="$token"

    # build curl arguments
    local curl_args=()
    for key in "${!headers[@]}"; do
        curl_args+=( -H "$key: ${headers[$key]}" )
    done

    # create the file to store the dumped data
    local file="dump_${channel_id}.txt"

    local query_parameters="limit=50"
    local before_last_id=
    local last_message_id=
    while [[ true ]]; do
        if [[ -n $last_message_id ]]; then
            if [[ $before_last_id == $last_message_id ]]; then
                break
            fi
            before_last_id="$last_message_id"
            query_parameters+="&before=$last_message_id"
        fi

        local url="https://discord.com/api/v9/channels/${channel_id}/messages?${query_parameters}"
        response=$(curl -sS --http3 "${curl_args[@]}" "${url}")
        count=$(echo "$response" | jq 'length')

        echo "[+] Fetched <${count}>"
        echo "$response" >> "$file"

        last_message_id=$(echo "$response" | jq -r '.[-1].id')
        sleep 1
    done
}

# $@ expands to all positional arugments
parse-options "$@"

# check required arguments
if [[ -z "$token" || -z "$channel_id" ]]; then
    echo "Error: both -t (token) and -c (channel_id) are required." >&2
    usage
    exit 1
fi

main
